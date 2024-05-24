# Kubernetes for Inference in Nebius AI

## Features

- Creating a zonal Kubernetes cluster with CPU and GPU nodes.
- Installing the necessary [Nvidia tools](https://github.com/NVIDIA/gpu-operator) for running GPU workloads.
- Installing [Descheduler](https://github.com/kubernetes-sigs/descheduler/).
- Example workloads.

## Define the Kubernetes cluster 

Start by creating  a VPC network with a subnet in eu-north1-c zone!

The Kubernetes module requires the following input variables:
 - VPC network ID
 - VPC network subnet IDs



## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart).
- Add environment variables for Terraform authentication in Nebuis Cloud.

```
export YC_TOKEN=$(ncp iam create-token)
export YC_CLOUD_ID=$(ncp config get cloud-id)
export YC_FOLDER_ID=$(ncp config get folder-id)
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | > 3.3 |
| <a name="requirement_nebius"></a> [nebius](#requirement\_nebius) | > 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_nebius"></a> [nebius](#provider\_nebius) | 0.91.0 |
