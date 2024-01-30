
# Kubernetes Deploy: Nvidia Generative AI Playground

A terraform-helm runbook which provisions a k8s cluster and installs [Nvidia Generative AI examples](https://github.com/NVIDIA/GenerativeAIExamples/tree/main).


## llm server
In this example, we are using a llama2-13b-chat model, which is during runtime converted to run with TensorRT engine, as well as quantized using int4_awq quantization. If you want to play with the quantizaton, or other TensorRT options, you can modify a ConfigMap in [this file](./helm/templates/triton.yaml): 

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: triton-entrypoint
data:
  entrypoint.sh: |-
    #!/bin/bash -x
    set -e

    rm -rf /usr/local/cuda-12.2/targets/x86_64-linux/lib/stubs/   
    ldconfig 
    
    /usr/bin/python3 -m  model_server {{ .Values.triton.modelArchitecture | quote }}  \
      --max-input-length {{ .Values.triton.modelMaxInputLength | quote}} \
      --max-output-length {{ .Values.triton.modelMaxOutputLength | quote}} \
      --quantization int4_awq
  ```
You can find a full list of available parameters [here](https://github.com/NVIDIA/GenerativeAIExamples/blob/main/RetrievalAugmentedGeneration/llm-inference-server/model_server/__main__.py)



## Install Instructions


### Downloading the model

Download llama2 model as explained [here](https://github.com/NVIDIA/GenerativeAIExamples/tree/main/RetrievalAugmentedGeneration#downloading-the-model). This helm chart works well with llama2-13b-chat, if you want to try llama2-70b-chat, you will need to increase resources requests for the llm server in the chart.


Triton Server needs a repository of models that it will make available
for inferencing. For this example you will place the model repository
in an Nebius Storage bucket. Nebius Storage is fully s3 compatible, and you can use aws cli to upload the files. Please follow nebius.ai documentation on how to [create a bucket](https://nebius.ai/docs/storage/operations/buckets/create) and how to [upload the files](https://nebius.ai/docs/storage/operations/objects/upload)


```
aws --endpoint-url=https://storage.ai.nebius.cloud/ \
  s3 cp --recursive <path_to_local_directory>/ s3://<bucket_name>/<prefix>/
```

### Nebius Model Repository
To load the model from the Nebius Object storage, you need to 
- Create a [service account](https://nebius.ai/docs/iam/operations/sa/create) with the storage.editor [role](https://nebius.ai/docs/iam/concepts/access-control/roles)
- [Create a static access key](https://nebius.ai/docs/iam/operations/sa/create-access-key) for the service account.

- Edit [values.yaml](./helm/values.yaml) file:
```
triton:
  s3:
    volumeHandle: <bucket-name>/<folder-name>
    accessKeyID: #accessKey
    secretAccessKey: #secretKey
```

volumeHandle param is a path to your llama2 model, and it is a combination of bucket-name and folder-name, you can also construct a folder path if you have child folders.

### Running terraform 

Once model has been uploaded and helm chart values.yaml file edited, you can also set the proper values in [tfvars](./k8s-terraform/terraform.tfvars) file:

```
folder_id = "bjern66lia66ph1betqn"
network_id = "btc1dleq5piffnlnvejh"
subnet_id = "f8uhuvfkk7vuj4d9ja2k"
```

Then, terraform will take care of the rest

```
cd k8s-terraform
terraform init
terraform apply
```



## notebook

The runbook hosts a notebook with examples for chaining and using vector DB. To open the notebook you can:

```
kubectl port-forward service/jupyter-notebook-service 8888:8888
```
In vs code, choose "Open Folder" -> /app and then you can run the provided jupyter notebook examples.
You can also check GPU resource the notebook has by running "nvidia-smi" in the terminal :

```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.12             Driver Version: 535.104.12   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA H100 80GB HBM3          On  | 00000000:8B:00.0 Off |                   On |
| N/A   48C    P0             138W / 700W |                  N/A |     N/A      Default |
|                                         |                      |              Enabled |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| MIG devices:                                                                          |
+------------------+--------------------------------+-----------+-----------------------+
| GPU  GI  CI  MIG |                   Memory-Usage |        Vol|      Shared           |
|      ID  ID  Dev |                     BAR1-Usage | SM     Unc| CE ENC DEC OFA JPG    |
|                  |                                |        ECC|                       |
|==================+================================+===========+=======================|
|  0    9   0   0  |              12MiB /  9984MiB  | 16      0 |  1   0    1    0    1 |
|                  |               0MiB / 16383MiB  |           |                       |
+------------------+--------------------------------+-----------+-----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
```

In our case, we have given this notebook a MIG device with single gpu core and 10GB memory. If you want to increase, you can change this in the values.yaml file. More on the MIG manager later in this doc.



## llm playground

The runbook installs a simple web chat feature. You can upload pdf or any text files to Milvus vector DB, and query the model through chat.
```
kubectl port-forward service/frontend-service 8090:8090
```

## GPU and Mig manager

This example also demonstrates Nvidia's [MIG Support in Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/kubernetes/latest/index.html). It installs a gpu operator with mig.strategy = mixed, which allows to have mig manager turn on or off on the individual nodes, depending on "nvidia.com/mig.config" label. For instance, in this example we have two node groups, one of which sets this label to "all-balanced", which will result in the following mig slices:
```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.12             Driver Version: 535.104.12   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA H100 80GB HBM3          On  | 00000000:8B:00.0 Off |                   On |
| N/A   51C    P0             140W / 700W |   1764MiB / 81559MiB |     N/A      Default |
|                                         |                      |              Enabled |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| MIG devices:                                                                          |
+------------------+--------------------------------+-----------+-----------------------+
| GPU  GI  CI  MIG |                   Memory-Usage |        Vol|      Shared           |
|      ID  ID  Dev |                     BAR1-Usage | SM     Unc| CE ENC DEC OFA JPG    |
|                  |                                |        ECC|                       |
|==================+================================+===========+=======================|
|  0    2   0   0  |              37MiB / 40320MiB  | 60      0 |  3   0    3    0    3 |
|                  |               0MiB / 65535MiB  |           |                       |
+------------------+--------------------------------+-----------+-----------------------+
|  0    3   0   1  |              25MiB / 20096MiB  | 32      0 |  2   0    2    0    2 |
|                  |               0MiB / 32767MiB  |           |                       |
+------------------+--------------------------------+-----------+-----------------------+
|  0    9   0   2  |              12MiB /  9984MiB  | 16      0 |  1   0    1    0    1 |
|                  |               0MiB / 16383MiB  |           |                       |
+------------------+--------------------------------+-----------+-----------------------+
|  0   10   0   3  |            1688MiB /  9984MiB  | 16      0 |  1   0    1    0    1 |
|                  |               2MiB / 16383MiB  |           |                       |
+------------------+--------------------------------+-----------+-----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   10    0      51445      C   /usr/bin/python3                           1668MiB |
+---------------------------------------------------------------------------------------+
```

.. whereas other nodegroup will have Mig manager turned off: 

```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.12             Driver Version: 535.104.12   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA H100 80GB HBM3          On  | 00000000:8B:00.0 Off |                    0 |
| N/A   37C    P0             122W / 700W |  72135MiB / 81559MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A     24856      C   /opt/tritonserver/bin/tritonserver        72122MiB |
+---------------------------------------------------------------------------------------+
```

this gives us the possibillity to use less than full GPU for resources like Milvus DB, Notepad, and Query server. You can find examples how to set nvidia mig resources in the [values.yaml](./helm/values.yaml) file.

Once gpu operator is deployed, you can also find the possible options how to label your nodes in the gpu-opeator namespace:

```
kubectl describe configmap default-mig-parted-config -n gpu-operator
```