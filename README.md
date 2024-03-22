# Nebius Architect Solution Library

## Table of contents
* [Introduction](#introduction)
* [Solutions](#solutions)
* [Prerequisites](#prerequisites)
---
## Introduction
Nebius Architect Solution Library is a collection of infrastucture as code samples to deploy various platforms and applications on [Nebius AI Cloud](https://nebius.ai/).

---
## Solutions

### Infrastructure
* [Kubernetes examples](ml-k8s-iaac/README.md)
* [GlusterFS](glusterfs-cluster-ubuntu/README.md)
* [GlusterFS Benchmark](glusterfs-for-benchmarks/README.md)
* [JuiceFS Benchmark](juicefs-for-benchmarks/README.md)
### Model Training
* [Kubeflow](kubeflow/README.md)
### Inference
* [NVIDIA Triton Server](nvidia-triton-server/README.md)
* [Nvidia Generative AI examples](generative-ai-examples/nvidia-playground/README.md)

---
## Prerequisites
These samples use mainly [Terraform](https://www.terraform.io/) to deploy architectures on Nebius AI Cloud. For detailed documentation on how to work with Terraform and Nebius AI, please refer to our [documentation](https://nebius.ai/docs/terraform/).

To access Nebius AI API, you will need to install the [Nebius AI CLI](https://nebius.ai/docs/cli/)