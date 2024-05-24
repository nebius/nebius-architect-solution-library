# Kubeflow installation for Nebius AI

## Features

- Full Kubelfow installation with Notebooks, Pipelines, Training Operator, KServe, Katib, Dex, Istio, etc.
- Integration with the Nebius Object Storage as an artifactory for pipelines and training.


## Prerequisites

First, provision K8s cluster with GPU support, as explained [here](../ml-k8s-iaac/README.md)

## Installation instructions

### Object storage

- Create a bucket. Keep in mind that you will need the name of the bucket for future reference. -(https://nebius.ai/docs/storage/operations/buckets/create) Please follow the nebius.ai instructions to [create a bucket](https://nebius.ai/docs/storage/operations/buckets/create)
- Update the bucket name in the [s3 config file](./nebius-deployment/patches/s3.yaml)

- Create a [service account](https://nebius.ai/docs/iam/operations/sa/create) with the storage.uploader [role](https://nebius.ai/docs/iam/concepts/access-control/roles)
- [Create a static access key](https://nebius.ai/docs/iam/operations/sa/create-access-key) for the service account.
- Update s3 credentials in the [secrets](./nebius-deployment/patches/secrets.yaml) file

### User namespace
- To change the default namespace and user, modify the following files:
    - kubeflow/nebius-deployment/patches/params.env
    - kubeflow/nebius-deployment/patches/dex.yaml

### Node selector

The script is configured to deploy Kubeflow to the node group labeled "group: system" by default. You can change this in the kubeflow/nebius-deployment/kustomization.yaml:


```
  - patch: |-
      kind: not-important
      metadata:
        name: not-important
      spec:
        template:
          spec:
            nodeSelector:
              group: system

```

### Install command

Run the [bash script](./hack/setup-kubeflow.sh) to install kubeflow:



```
bash ./hack/setup-kubeflow.sh
```