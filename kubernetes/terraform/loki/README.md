# Loki Stack Terraform Module

This repository contains a Terraform module for
deploying [Loki-Stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack) into an existing cluster. The
module creates a Nebius Storage Bucket, a service account with editor rights and installs
a [Loki-Stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack) Helm chart into a specified cluster.
It's meant to be used as a part of [kubernetes-inference](../kubernetes-inference/README.md)
or [kubernetes-training](../kubernetes-training/README.md) modules and is enabled there by default.

## Manual Installation
It's possible to install Loki-Stack into a pre-existing cluster manually using Helm.

#### Prerequisites

- [Helm client](https://helm.sh) connected to the chosen cluster.

#### Instructions

- [Create a Nebius Storage bucket](https://nebius.ai/docs/storage/operations/buckets/create).
- [Create a Service Account](https://nebius.ai/docs/iam/operations/sa/create).
- [Add the created Service Account to `editors group`](https://nebius.ai/docs/iam/operations/groups/add-member).
- [Create a Static Access Key](https://nebius.ai/docs/iam/operations/sa/create-access-key) for the Service Account.
- Copy `./files/loki-values.yaml.tfpl` to `./files/loki-values.yaml`. In copied file replace:
    - `${loki_bucket}` with a name of the bucket created on the first step.
    - `${s3_access_key}` with Access Key from the Static Access Key.
    - `${s3_secret_key}` with Secret Key from the Static Access Key
- Prepare Helm chart to be installed with the following commands:

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

- Install the chart using prepared `./files/loki-values.yaml` file:

```shell
helm install loki-stack grafana/loki-stack -n loki -f ./files/loki-values.yaml --create-namespace 
```
