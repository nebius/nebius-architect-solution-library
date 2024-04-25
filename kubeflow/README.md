# Kubeflow installation for Nebius.ai

This playbook provisions new K8s cluster with GpuOperator, and installs Kubeflow with integrated Nebius Object storage and MySql cluster. Optionally, for training purposes it can be configured to use infiniband connection and NetworkOperator.

Our Helm chart is specifically designed to leverage DeployKF along with ArgoCD to facilitate the streamlined installation and management of our Kubernetes applications.

## Features

- Kubernetes cluster with GpuOperator and NetworkOperator
- Full Kubelfow installaton with Notebooks, Pipelines, Training Operator, KServe, Katib, Dex, Istio, etc.
- Integration with Nebius Object Storage as artifactory for pipelines and training.
- Integration with Nebius MySql managed service



## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export NPC_TOKEN=$(ncp iam create-token)
export NPC_CLOUD_ID=$(ncp config get cloud-id)
export NPC_FOLDER_ID=$(ncp config get folder-id)
```

## Install instructions

- Set folder_id, region, and username (mysql user) in [terraform.tfvars](./terraform/terraform.tfvars) configuration file
- In [main.tf](./terraform/main.tf) file define which kf-kubernetes module you want to use, and set apropriate values for node group. Deneding on your use case, you can choose the nodegroup setup optimized for either training or inference:

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
cd kubeflow/terraform
terraform init
terraform apply
```

