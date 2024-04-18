# Kubeflow installation for Nebius.ai

This playbook provisions new K8s cluster with infiniband connection, GpuOperator, NetworkOperator, and installs Kubeflow with integrated Nebius Object storage and MySql cluster.

## Features

- Kubernetes cluster with GpuOperator and NetworkOperator
- Full Kubelfow installaton with Notebooks, Pipelines, Training Operator, KServe, Katib, Dex, Istio, etc.
- Integration with Nebius Object Storage as artifactory for pipelines and training.
- Integration with Nebius MySql managed service


## Kubernetes cluster definition

First, you need to create a VPC network with a subnet in eu-north1-c zone.

The Kubeflow module requires the following input variables:
 - VPC folder ID
 - VPC network ID
 - VPC network subnet IDs
 - MySql username



## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export YC_TOKEN=$(ncp iam create-token)
export YC_CLOUD_ID=$(ncp config get cloud-id)
export YC_FOLDER_ID=$(ncp config get folder-id)
```

## Install instructions

- Configure Kubernetes cluster node groups 