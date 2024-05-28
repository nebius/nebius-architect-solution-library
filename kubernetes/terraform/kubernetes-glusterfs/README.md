# Kubernetes and GlusterFS playbook

## Features

- Create zonal Kubernetes cluster with CPU and GPU nodes
- Create a GlusterFS cluster and connect it to the Kubernetes cluster

## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud with commands bellow or run `sh ./environment.sh`

```
export YC_TOKEN=$(ncp iam create-token)
export YC_CLOUD_ID=$(ncp config get cloud-id)
export YC_FOLDER_ID=$(ncp config get folder-id)
```

## Configurable Variables

All the configurable variables are defined in the `variables.tf` file. You can find and modify these variables to suit
your requirements.

### GlusterFS Cluster Parameters

- **storage_nodes**: (number) Number of storage nodes. Default is 3.
- **disk_size**: (number) Disk size in GB. Default is 100.
- **disk_type**: (string) Disk type. Default is `network-ssd`.
- **ssh_pubkey**: (string) SSH public key to access the cluster nodes. Default is an empty string.

### Kubernetes Cluster Parameters

- **cpu_nodes_count**: (number) Amount of CPU only nodes. Default is 3.
- **gpu_nodes_count**: (number) Amount of GPU nodes. Default is 1.
- **platform_id**: (string) Platform ID for GPU nodes. Default is `gpu-h100`.
- **glusterfs_mount_host_path**: (string) Mount host path for GlusterFS. Default is `/shared`.

## Installation instructions
- Run Terraform :

```
terraform init
terraform apply
```

## Usage example
Below is an example `daemonset.yaml` template for accessing shared GlusterFS storage. Replace `<var.glusterfs_mount_host_path>` with the value specified for the `glusterfs_mount_host_path` variable in your configuration.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: example-pod
spec:
  selector:
    matchLabels:
      app: example-pod-app
  template:
    metadata:
      labels:
        app: example-pod-app
    spec:
      containers:
        - name: example-container
          image: ubuntu:latest
          command: [ "/bin/sh", "-c" ]
          args:
            - "sleep infinity"
          volumeMounts:
            - name: host-volume
              mountPath: /mnt
      volumes:
        - name: host-volume
          hostPath:
            path: <var.glusterfs_mount_host_path>
            type: Directory
```