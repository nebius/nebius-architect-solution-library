# Observability stack Terraform module

This repository contains a Terraform module for
deploying following into an existing cluster.

- Installing [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana).
- Installing [Prometheus](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus).
- Installing [Loki](https://github.com/grafana/loki/tree/main/production/helm/loki).
- Installing [Promtail](https://github.com/grafana/helm-charts/tree/main/charts/promtail).

The module creates a Nebius Storage Bucket, a service account with editor rights.
It's meant to be used as a part of [kubernetes-inference](../kubernetes-inference/README.md)
or [kubernetes-training](../kubernetes-training/README.md) modules and is enabled there by default.

### Grafana

Could be disabled by setting follwing in `terraform.tfvars`:
```terraform
o11y = {
  grafana = false
}
```

To access Grafana:

1. **Port-Forward to the Grafana Service:** Run the following command to port-forward to the Grafana service:
   ```shell
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
    node_groups = {
      h100 = {
        gpus              = 2
        instance_group_id = "a4h6ollme7ijmppk0stu"
      }
    }
  }
}
```

## Manual Installation
It's possible to install Observability stack into a pre-existing cluster.
Obtain cluster configuration for kubectl [ncp container cluster get-credentials](https://nebius.ai/docs/cli/cli-ref/managed-services/container/cluster/get-credentials)
Set kubectl configuration path

```shell
export KUBE_CONFIG_PATH=~/.kube/config
```

Configure module settings in `terraform.tfvars`

Run terraform init and apply
```shell
terraform init
terraform apply
```
