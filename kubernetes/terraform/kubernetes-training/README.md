# Kubernetes for Training in Nebius AI

## Features

- Creating a zonal Kubernetes cluster with CPU and GPU nodes and InfiniBand connection.
- Install the necessary [Nvidia Gpu Operator](https://github.com/NVIDIA/gpu-operator) and [Network Operator](https://docs.nvidia.com/networking/display/cokan10/network+operator) for running GPU workloads.



## Defining Kubernetes cluster 

Start by creating a VPC network with a subnet in eu-north1-c zone!

The Kubernetes module requires the following input variables:
 - VPC network ID
 - VPC network subnet IDs

## Configuring Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart).
- Add environment variables for Terraform authentication in Nebuis Cloud.

```
export YC_TOKEN=$(ncp iam create-token)
export YC_CLOUD_ID=$(ncp config get cloud-id)
export YC_FOLDER_ID=$(ncp config get folder-id)
```

## Configuring GPU Environment

There are two types of gpu environment:
- "runc_drivers_cuda" - uses images with preinstalled GPU drivers. Used by default. 
- "runc" - uses plain VM image for the GPU nodes. GPU drivers are installed via nvidia gpu-operator, which on one hand ensures the latest driver installation, on the other hand it results in added time for new node deplyment during autoscaling
  
To use runc environment, add the following string to the terraform.tfvars file
```
gpu_env = "runc"
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
