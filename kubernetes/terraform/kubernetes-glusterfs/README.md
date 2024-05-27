# Kubernetes and GlusterFS playbook

## Features

- Create zonal Kubernetes cluster with CPU and GPU nodes
- Install neccessary [Nvidia tools](https://github.com/NVIDIA/gpu-operator) to run GPU workloads
- Create a [FileStorage](https://nebius.ai/docs/compute/concepts/filesystem) virtual file syсtem and attach it to all the nodes



## Limitation

This example works well with a fixed k8s node-group. If you scale your node groups, new nodes will not have the filestorage mounted.

## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export YC_TOKEN=$(ncp iam create-token)
export YC_CLOUD_ID=$(ncp config get cloud-id)
export YC_FOLDER_ID=$(ncp config get folder-id)
```

## Configure jq cli

This example uses jq cli tool. Please follow [official documentation](https://jqlang.github.io/jq/download/) how to install

## Install instructions

- Set folder_id, disk size and node count in [terraform.tfvars](./terraform/terraform.tfvars) configuration file
- In [main.tf](./terraform/main.tf) file define which kf-kubernetes module you want to use, and set apropriate values for node group.
  Depending on your use case, you can choose the nodegroup setup optimized for either training or inference:

```
module "kf-cluster"{
  source = "../../kubernetes/terraform/kubernetes-inference"
  folder_id = var.folder_id
  zone_id = var.region
  gpu_min_nodes_count = 0
  gpu_max_nodes_count = 8
  gpu_initial_nodes_count = 1
  platform_id = "gpu-h100"
}

# module "kf-cluster"{
#   source = "../../kubernetes/terraform/kubernetes-training"
#   folder_id = var.folder_id
#   zone_id = var.region
#   gpu_nodes_count = 2
#   platform_id = "gpu-h100"
# }
```

- Run Terraform :

```
terraform init
terraform apply
```

- Run example deployment with mounted shared storage: 

```
kubectl apply -f test-deployment.yaml
```
