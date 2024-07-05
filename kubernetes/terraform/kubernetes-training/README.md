# Kubernetes for Training in Nebius AI

## Features

- Creating a zonal Kubernetes cluster with CPU and GPU nodes and InfiniBand connection.
- Installing the necessary [Nvidia Gpu Operator](https://github.com/NVIDIA/gpu-operator) and [Network Operator](https://docs.nvidia.com/networking/display/cokan10/network+operator) for running GPU workloads.
- Installing [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana).
- Installing [Prometheus](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus).
- Installing [Loki](https://github.com/grafana/loki/tree/main/production/helm/loki).
- Installing [Promtail](https://github.com/grafana/helm-charts/tree/main/charts/promtail).


## Defining Kubernetes cluster

Start by creating a VPC network with a subnet in eu-north1-c zone!

The Kubernetes module requires the following input variables:
 - VPC network ID
 - VPC network subnet IDs

## Configuring Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart).
- Add environment variables for Terraform authentication in Nebuis Cloud.

```shell
export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)
```
## Storage

For a shared distributed storage, [GlusterFS](https://www.gluster.org/) cluster can be provisioned with following parameters in [terraform.tfvars](./terraform.tfvars): 

```terraform
shared_fs_type = "gluster"
gluster_disk_size = 930 # has to be divisible by 930
gluster_disks_per_vm = 1
gluster_nodes= 10
glusterfs_mount_host_path = "/shared"
```

This will provision glusterfs, and also mount the gluster volume to each node in th ecluster. You can then use a [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) k8s volume to mount to multiple pods:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    volumeMounts:
      - name: host-volume
        mountPath: /shared
  volumes:
    - name: host-volume
      hostPath:
        path: /shared
        type: Directory
```

## Observability

Observability stack is enabled by default. It consist of the following:
 - Grafana
 - Prometheus
 - Loki

### Grafana

Could be disabled by setting follwing in `terraform.tfvars`:
```terraform
o11y = {
  grafana = false
}
```

To access Grafana:

1. **Port-Forward to the Grafana Service:** Run the following command to port-forward to the Grafana service:
   ```sh
   kubectl --namespace o11y port-forward service/grafana 8080:80
   ```

2. **Access Grafana Dashboard:** Open your browser and navigate to `http://localhost:8080`.

3. **Log In:** Use the default credentials to log in:
   - **Username:** `admin`
   - **Password:** `admin`

### Log Aggregation

Log aggregation with the Loki is enabled by default. If you need to disable it, add the following string to the `terraform.tfvars` file.
```terraform
o11y = {
  loki = false
}
```

To access logs navigate to Loki dashboard `http://localhost:8080/d/o6-BGgnnk/loki-kubernetes-logs`

### Prometheus

Prometheus server is enabled by default. If you need to disable it, add the following string to the `terraform.tfvars` file.
Because `Node exporter` and `DCGM exporter` uses Prometheus as a datasource they will be disabled as well.

```terraform
o11y = {
  prometheus = {
    enabled = false
  }
}
```

### Node exporter

Prometheus node exporter is enabled by default. If you need to disable it, add the following string to the `terraform.tfvars` file.

```terraform
o11y = {
  prometheus = {
    node_exporter = false
  }
}
```

To access logs navigate to Node exporter folder `http://localhost:8080/f/e6acfbcb-6f13-4a58-8e02-f780811a2404/`


### NVIDIA DCGM Exporter Dashboard and Alerting

NVIDIA DCGM Exporter Dashboard and Alerting rules are enabled by default. If you need to disable it, add the following string to the `terraform.tfvars` file.

```terraform
o11y = {
  dcgm = {
    enabled = false
  }
}
```

By default Alerting rules are created for node groups that has GPUs.

To access NVIDIA DCGM Exporter Dashboard `http://localhost:8080/d/Oxed_c6Wz/nvidia-dcgm-exporter-dashboard`

### Alerting

To enable alert messages for Slack please refer this [article](https://grafana.com/docs/grafana/latest/alerting/configure-notifications/manage-contact-points/integrations/configure-slack/)

### Complete configuration

All settings of observability could be merged into following configuration:

```terraform
o11y = {
  grafana = false
  loki    = false
  prometheus = {
    enabled = false
  }
  dcgm = {
    enabled = false
  }
}
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
