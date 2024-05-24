<!--
# Copyright (c) 2018-2023, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted, provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->

[![License](https://img.shields.io/badge/License-BSD3-lightgrey.svg)](https://opensource.org/licenses/BSD-3-Clause)

# Kubernetes deployment: Triton Inference Server cluster

A helm chart for installing a single cluster of Triton Inference Server is provided. By default the cluster contains a single instance of the inference server but the *replicaCount* configuration parameter can be set to create a cluster of any size, as described below.

This guide assumes you already have a functional Kubernetes cluster and Helm installed (see below for installation instructions). Consider the following requirements:

* The helm chart deploys Prometheus and Grafana to collect and display Triton metrics. To use this Helm chart, you must first install Prpmetheus and Grafana in your cluster, as described below, and ensure that your cluster has enough CPU resources to run these services. 

* If you want Triton Server to use GPUs for inferencing, your cluster must be configured to include the necessary number of GPU nodes (EC2 G4 instances are recommended), as well as support for the NVIDIA driver and CUDA version required by the inference server version you are using.

The steps below describe how to set up a model repository, use Helm to launch the inference server and send inference requests to the
running server. You can access a Grafana endpoint to view real-time metrics reported by the inference server.

## Installing Helm

### Helm v3

If you do not already have Helm installed in your Kubernetes cluster,
follow the steps in the  [official helm install
guide](https://helm.sh/docs/intro/install/) will for a quick setup.

If you're currently using Helm v2 and want to migrate to Helm v3,
please check out the [official migration guide](https://helm.sh/docs/topics/v2_v3_migration/).

### Helm v2

> **NOTE**: From now on, this chart will only be tested and maintained for Helm v3.

Installation instructions for Helm v2 are provided below.

```
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
$ kubectl create serviceaccount -n kube-system tiller
serviceaccount/tiller created
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller --wait
```

If you encounter any problems, please refer to the official installation guide [here](https://v2.helm.sh/docs/install/).

## Model repository

If you have an existing model repository, you can use it with this Helm
chart. If you do not have one, check out a local
copy of the inference server source repository and create an example
model repository:

```
$ git clone https://github.com/triton-inference-server/server.git
```

Triton Server requires a repository of models that it will be made available for inferencing. In this example, you will place the model repository in a Nebius Storage bucket. Nebius Storage is fully 
 compatible, and you can upload files using the aws cli. Check out Nebius AI documentation on how to [create a bucket](https://nebius.ai/docs/storage/operations/buckets/create) and how to [upload the files](https://nebius.ai/docs/storage/operations/objects/upload)


```
aws --endpoint-url=https://storage.ai.nebius.cloud/ \
  s3 cp --recursive <path_to_local_directory>/ s3://<bucket_name>/<prefix>/
```

### Nebius model repository
To load the model from the Nebius Object storage, follow these steps:
- Create a [service account](https://nebius.ai/docs/iam/operations/sa/create) with the storage editor [role](https://nebius.ai/docs/iam/concepts/access-control/roles).
- [Create a static access key](https://nebius.ai/docs/iam/operations/sa/create-access-key) for the service account.
- Convert the following Static access key credentials in the base64 format and add it to the values.yaml file.


```
echo -n 'SECRECT_KEY_ID' | base64
```
```
echo -n 'SECRET_ACCESS_KEY' | base64
```

## Deploy Prometheus and Grafana

The inference server metrics are collected using Prometheus and can be viewed in Grafana. The inference server helm chart assumes the availability of both Prometheus and Grafana. However, even if you do not want to use Grafana, you still have to complete this step.

To install these components, use [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).*serviceMonitorSelectorNilUsesHelmValues* flag is required forPrometheus to find the inference server metrics in the *example* release deployed below.

```
$ helm install example-metrics --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false prometheus-community/kube-prometheus-stack
```

Port-forward to the Grafana service to access it from your local browser.

```
$ kubectl port-forward service/example-metrics-grafana 8080:80
```

You should now be able to navigate your browser to localhost:8080 and see the Grafana login page. Use username=admin and password=prom-operator to login.

An example of the Grafana dashboard is available in dashboard.json. Use the import function in Grafana to import and view this dashboard.

## Deploy the Inference Server

Deploy the inference server in its  default configuration using the following commands.

```
$ cd <nvidia-triton-server directory>
$ helm install triton-server .
```

Use kubectl to check status and wait until the inference server pods are up and running.

```
$ kubectl get pods
NAME                                               READY   STATUS    RESTARTS   AGE
example-triton-inference-server-5f74b55885-n6lt7   1/1     Running   0          2m21s
```

The [helm
documentation](https://helm.sh/docs/using_helm/#customizing-the-chart-before-installing) outlines various methods for overriding the default configuration.

You can edit the values.yaml file directly or use the *--set* option to override a single parameter with the CLI. To deploy a cluster of four inference servers, use *--set* to specify the replicaCount parameter.

```
$ helm install example --set replicaCount=4 .
```

You can also write your own "config.yaml" file with the values you want to override and send it to Helm.

```
$ cat << EOF > config.yaml
namespace: MyCustomNamespace
image:
  imageName: nvcr.io/nvidia/tritonserver:custom-tag
  modelRepositoryPath: gs://my_model_repository
EOF
$ helm install example -f config.yaml .
```

## Using Triton Inference Server

Once the inference server is up and running, you can send HTTP or GRPC requests to perform inferencing. By default, the inferenceservice is exposed with a LoadBalancer service type. To determine the external IP for the inference server, execute the following command. In this example, the external IP is 34.83.9.133.

```
$ kubectl get services
NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                        AGE
...
example-triton-inference-server  LoadBalancer   10.18.13.28    34.83.9.133   8000:30249/TCP,8001:30068/TCP,8002:32723/TCP   47m
```

The inference server exposes three endpoints: HTTP on port 8000, GRPC on port 8001, and Prometheus metrics on port 8002. Use curl to retrieve the inference server's meta-data from the HTTP endpoint.

```
$ curl 34.83.9.133:8000/v2
```

Follow the [QuickStart](../../docs/getting_started/quickstart.md) to get the example
image classification client that can be used to perform inferencing using image classification models served by the inference server: 

```
$ image_client -u 34.83.9.133:8000 -m inception_graphdef -s INCEPTION -c3 mug.jpg
Request 0, batch size 1
Image 'images/mug.jpg':
    504 (COFFEE MUG) = 0.723992
    968 (CUP) = 0.270953
    967 (ESPRESSO) = 0.00115997
```

## Cleanup

Once you've finished using the inference server, use Helm to delete the deployment.

```
$ helm list
NAME            REVISION  UPDATED                   STATUS    CHART                          APP VERSION   NAMESPACE
example         1         Wed Feb 27 22:16:55 2019  DEPLOYED  triton-inference-server-1.0.0  1.0           default
example-metrics 1         Tue Jan 21 12:24:07 2020  DEPLOYED  prometheus-operator-6.18.0     0.32.0        default

$ helm uninstall triton-server
$ helm uninstall example-metrics
```


Make sure to [explicitly delete
CRDs](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#uninstall-helm-chart) for both Prometheus and Grafana services:

```
$ kubectl delete crd alertmanagerconfigs.monitoring.coreos.com alertmanagers.monitoring.coreos.com podmonitors.monitoring.coreos.com probes.monitoring.coreos.com prometheuses.monitoring.coreos.com prometheusrules.monitoring.coreos.com servicemonitors.monitoring.coreos.com thanosrulers.monitoring.coreos.com
```

You may also want to [delete the models](https://nebius.ai/docs/storage/operations/objects/delete-all) that were created to house the model repository.


