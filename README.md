# Nebius Architect Solution Library

## Table of contents
* [Introduction](#introduction)
* [Solutions](#solutions)
* [Prerequisites](#prerequisites)
---
## Introduction
This repository is a curated collection of Terraform and Helm solutions designed to streamline the deployment and management of AI and ML applications on Nebius AI Cloud.  Our solutions library has the tools and resources to help you deploy complex machine learning models, manage scalable infrastructure and ensure that your AI-powered applications run smoothly.


## General structure
The content is organized into sections based on common AI/ML use cases, so you can easily find the solutions you need.

---
## Solutions


### Training solutions
Training AI models at scale requires robust and flexible infrastructure. Our solutions support container orchestration with Kubernetes.

[Kubernetes prepared for Training](./kubernetes/terraform/kubernetes-training/README.md): For those who prefer containerized environments, our Kubernetes solution includes GPU-Operator and Network-Operator. This setup ensures that your training workloads use dedicated GPU resources and optimized network configurations, both of which are critical components for AI models that require a lot of computational power. . GPU-Operator simplifies the management of NVIDIA GPUs, automating the deployment of necessary drivers and plugins. Similarly, the Network-Operator improves network performance, ensuring seamless communication throughout your cluster. The cluster uses InfiniBand technology, which provides the fastest host connections for data-intensive tasks. 

[Kubeflow runbook](./kubeflow/README.md) expands the functionality of the Kubernetes training solution by installing Kubeflow and also integrating it with Nebius managed services such as Object Storage and MySQL cluster.



[Distributed training with SLURM](./slurm/slurm-standalone/README.md): Our SLURM solutions offer a streamlined approach for users who prefer traditional HPC environments. These solutions include ready-to-use images pre-configured with NVIDIA drivers and are ideal for those looking to take advantage of SLURM’s robust job scheduling capabilities.  Similar to our Kubernetes offerings, the SLURM solutions are optimized for InfiniBand connectivity, ensuring peak performance and efficiency in data transfer and communication between nodes.


## Inference solutions 

This collection is designed to streamline the deployment and management of ML inference environments on Kubernetes, utilizing Terraform as the infrastructure-as-code tool.

[Kubernetes prepared for inference](./kubernetes/terraform/kubernetes-inference/README.md): can be used to effectively scale-out your inference, if you are utilizing ML Inference servers such as TextGenerationInference, vLLM, or your own containerized application. The Kubernetes runbook creates a Kubernetes managed service and installs Nvidia’s GPU-Operator, which simplifies NVIDIA GPU management andautomates driver and plugin deployment.


[The Triton Inference Server](./nvidia-triton-server/README.md) offers a scalable solution for efficiently deploying machine learning models across various frameworks (e.g., TensorFlow, PyTorch and ONNX). It optimizes resource usage, while maintaining low-latency and high-throughput for both real-time and batch processing, making it ideal for streamlining model deployment in production environments.
 

[Kubeflow with KServe](./kubeflow/README.md) provides a serverless framework to efficiently deploy and manage machine learning models in Kubernetes environments. It simplifies the complexities of serving models by supporting such features as autoscaling, model versioning, and multi-framework integration. Designed for high-performance inference with minimal overhead, KServe is the go-to choice for streamlined model deployment.

## Storage solutions

Discover our Shared Storage Solutions for the Clouddesigned to offer seamless, scalable, and secure data storage across your cloud environments. Whether you’re collaborating on large-scale projects, managing extensive data sets, or looking to optimize your cloud infrastructure, our solutions provide a robust foundation for data sharing and storage. With features like real-time synchronization, easy access control, and high redundancy, your data is always available, secure and in sync.

[NFS Server](./storage/nfs/README.md):  Our NFS server solution offers a simple and reliable approach to network storage, making it ideal for those needing easy access to shared files. 

[GlusterFs](./storage/glusterfs-cluster-ubuntu/README.md) excels in distributed environments, providing a robust and scalable storage solution for managing large volumes of data across multiple servers seamlessly.


## RAG solutions
[RAG (Retrieval-Augmented Generation) Generative AI Solution](./generative-ai-examples/nvidia-playground/README.md) based on Nvidia technologies: a blend of language models and data retrieval produces AI-generated text with unprecedented precision and relevance. . This solution is designed for a wide range of applications, from improved customer support to streamlined content creation.  It combines detailed data retrieval with AI generative capabilities to ensure that responses are not only accurate but also contextually relevant.


## End-to-end solutions

[Our end-to-end solution with Kubeflow](./kubeflow/README.md) streamlines the machine learning workflow from concept to production on Kubernetes, offering a comprehensive toolkit for building, deploying, and managing scalable ML models. Our integrated platform, built on top of Kubeflow, simplifies the complexities of orchestrating machine learning pipelines, ensuring seamless model training, tuning, and deployment.  This approach not only accelerates the development cycle but also enhances model reliability and performance in production environments, empowering businesses to harness the full potential of their data with greater efficiency and precision.



---
## Prerequisites
These samples mainly use [Terraform](https://www.terraform.io/) to deploy architectures on Nebius AI Cloud. For detailed instructions on how to work with Terraform and Nebius AI, please see our [documentation](https://nebius.ai/docs/terraform/).

To access Nebius AI API, you will need to install the [Nebius AI CLI](https://nebius.ai/docs/cli/)