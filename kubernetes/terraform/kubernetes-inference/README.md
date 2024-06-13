# Kubernetes for Inference in Nebius AI

## Features

- Creating a zonal Kubernetes cluster with CPU and GPU nodes.
- Installing the necessary [Nvidia tools](https://github.com/NVIDIA/gpu-operator) for running GPU workloads.
- Installing [Descheduler](https://github.com/kubernetes-sigs/descheduler/).
- Installing [Loki-Stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack).
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

## Configuring GPU Environment

There are two types of gpu environment:
- "runc_drivers_cuda" - uses images with preinstalled GPU drivers. Used by default. 
- "runc" - uses plain VM image for the GPU nodes. GPU drivers are installed via nvidia gpu-operator, which on one hand ensures the latest driver installation, on the other hand it results in added time for new node deplyment during autoscaling
  
To use runc environment, add the following string to the `terraform.tfvars` file
```
gpu_env = "runc"
```

## Log Aggregation
Log aggregation with the Loki Stack is enabled by default. If you need to disable it, add the following string to the `terraform.tfvars` file.
```
log_aggregation = false
```

### Accessing Logs
To access the logs via Grafana:

1. **Port-Forward to the Grafana Service:** Run the following command to port-forward to the Grafana service:
   ```sh
   kubectl port-forward service/loki-stack-grafana 8080:80 -n loki
   ```

2. **Access Grafana Dashboard:** Open your browser and navigate to `http://localhost:8080`.

3. **Log In:** Use the default credentials to log in:
   - **Username:** `admin`
   - **Password:** `admin`

4. **View Logs:** Use included dashboard "Loki Kubernetes Logs" or create new ones.


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
