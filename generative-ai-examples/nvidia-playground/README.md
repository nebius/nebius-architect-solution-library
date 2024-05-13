# Kubernetes deployment: Nvidia Generative AI playground

A Terraform-helm runbook for creating a k8s cluster and installing [Nvidia Generative AI examples](https://github.com/NVIDIA/GenerativeAIExamples/tree/main).


## llm server
In this example, we use a llama2-13b-chat model that is converted during runtime to run with  TensorRT engine and quantized using int4_awq quantization. If you want to experiment with the quantizaton or other TensorRT setttings, you can modify a ConfigMap in [this file](./helm/templates/triton.yaml): 

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
The full list of available parameters can be found [here](https://github.com/NVIDIA/GenerativeAIExamples/blob/main/RetrievalAugmentedGeneration/llm-inference-server/model_server/__main__.py)



## Installation Instructions


### Downloading the model

Download llama2 model by following  [these instructions](https://github.com/NVIDIA/GenerativeAIExamples/tree/main/RetrievalAugmentedGeneration#downloading-the-model). This Helm chart is optimized to work with llama2-13b-chat. If you want to use llama2-70b-chat, increase the resource requests for the llm server within the chart accordingly.


Triton Server requires a model repository that will be made available for inference. In this example, you will store the model repository in a Nebius Storage bucket. Nebius Storage is fully S3 compatible, and you can upload files using the AWS CLI. Please follow nebius.ai documentation on how to [create a bucket](https://nebius.ai/docs/storage/operations/buckets/create) and how to [upload the files](https://nebius.ai/docs/storage/operations/objects/upload)


```
aws --endpoint-url=https://storage.ai.nebius.cloud/ \
  s3 cp --recursive <path_to_local_directory>/ s3://<bucket_name>/<prefix>/
```

### Nebius model repository
To load the model from the Nebius Object storage, follow these steps: 
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

The volumeHandle parameter is a path to your llama2 model that combines the bucket and folder names. If you have child folders, you can use them to create a folder path.

### Running Terraform 

Once the model has been uploaded and the helm chart values.yaml file has been edited, you can configure the appropriate values in the  [tfvars](./k8s-terraform/terraform.tfvars) file:

```
folder_id = "bjern66lia66ph1betqn"
network_id = "btc1dleq5piffnlnvejh"
subnet_id = "f8uhuvfkk7vuj4d9ja2k"
```

Terraform will handle the rest.

```
cd k8s-terraform
terraform init
terraform apply
```



## Notebook

The runbook hosts a notebook with examples for chaining and using vector DB. To access the notebook:

```
kubectl port-forward service/jupyter-notebook-service 8888:8888
```
In vs code, choose "Open Folder" -> /app and run the provided jupyter notebook examples.
You can also check the GPU resources of the notebook has by running "nvidia-smi" in the terminal :

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

In our case, we have assigned the notebook to a MIG device with a single GPU core and 10GB of memory. If you need to adjust these specifications, do so in the values.yaml file. Further details on the MIG manager will be provided later in this document.



## llm playground

The runbook installs a basic web chat feature. You can upload pdfs or any text files to the Milvus vector DB and query the model via chat.
```
kubectl port-forward service/frontend-service 8090:8090
```

## GPU and MIG manager

This example demonstrates Nvidia's [MIG Support in Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/kubernetes/latest/index.html). It installs a GPU operator with mig.strategy = mixed, allowing MIG manager to be enabled or disabled on individual nodes based on "nvidia.com/mig.config" label.  In this scenario, there are two node groups. One of them sets this label to "all-balanced," which produces the following MIG slices:
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

Other nodegroups will have MIG managers turned off: 

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

This gives us the flexibility to allocate less than the full GPU for resources such as Milvus DB, Notepad, and Query Server. You can find examples of how to configure Nvidia MIG resources  in the [values.yaml](./helm/values.yaml) file.

Once gpu operator is deployed, you can explore the available options for labeling your nodes within the gpu-operator namespace:

```
kubectl describe configmap default-mig-parted-config -n gpu-operator
```