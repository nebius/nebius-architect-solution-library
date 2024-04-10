# Kubernetes for Training in Nebius.ai

## Features

- Create zonal Kubernetes cluster with CPU and GPU nodes and InfiniBand connection.
- Install neccessary [Nvidia Gpu Operator](https://github.com/NVIDIA/gpu-operator) and [Network Operator](https://docs.nvidia.com/networking/display/cokan10/network+operator) to run GPU workloads



## Kubernetes cluster definition

First, you need to create a VPC network with a subnet in eu-north1-c zone!

The Kubernetes module requires the following input variables:
 - VPC network ID
 - VPC network subnet IDs

## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

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
| <a name="requirement_nebius"></a> [nebius](#requirement\_nebius) | >= 0.6.0" |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_nebius"></a> [nebius](#provider\_nebius) | 0.91.0 |
