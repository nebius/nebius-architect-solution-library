# Kubeflow installation for Nebius.ai

## Features

- Full Kubelfow installaton with Notebooks, Pipelines, Training Operator, KServe, Katib, Dex, Istio, etc.
- Integration with Nebius Object Storage as artifactory for pipelines and training.


## Prerequisites

First, you need to provision K8s cluster with GPU support as explained [here](../ml-k8s-iaac/README.md)

## Install instructions

### Object Storage

- Create a bucket, the name of the bucket will need to be referenced later. Please follow nebius.ai documentation on how to [create a bucket](https://nebius.ai/docs/storage/operations/buckets/create)
- Replace the bucket name in the [s3 config file](./nebius-deployment/patches/s3.yaml)

- Create a [service account](https://nebius.ai/docs/iam/operations/sa/create) with the storage.uploader [role](https://nebius.ai/docs/iam/concepts/access-control/roles)
- [Create a static access key](https://nebius.ai/docs/iam/operations/sa/create-access-key) for the service account.
- Replace s3 credentials in the [secrets](./nebius-deployment/patches/secrets.yaml) file

### User namespace
- You can change the default namespace and user by modifying these files:
    - kubeflow/nebius-deployment/patches/params.env
    - kubeflow/nebius-deployment/patches/dex.yaml

### Node Selector

By default, the scipt is defined to deploy Kubeflow to the node group with label "group: system". You can modify this in the kubeflow/nebius-deployment/kustomization.yaml:


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

Run the [bash script](./hack/setup-kubeflow.sh) to install kubeflow :



```
bash ./hack/setup-kubeflow.sh
```
