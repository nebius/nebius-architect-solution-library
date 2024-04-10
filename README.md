# Nebius Architect Solution Library

## Table of contents
* [Introduction](#introduction)
* [Solutions](#solutions)
* [Prerequisites](#prerequisites)
---
## Introduction
This repository is a curated collection of Terraform and Helm solutions designed to streamline the deployment and management of AI and ML applications on Nebius.ai cloud. Whether you are looking to deploy complex machine learning models, manage scalable infrastructure, or ensure the seamless operation of your AI-driven applications, our solutions library offers the tools and resources to make your journey easier and more efficient.


## General Stucture
The content is organized into sections based on common AI/ML use cases, ensuring you can easily navigate to the solutions most relevant to your needs.

---
## Solutions


### Training Solutions
Training AI models at scale requires robust and flexible infrastructure. Our solutions support container orchestration with Kubernetes, enhanced with GPU and network operators for performance and efficiency.

[Kubernetes prepared for Training:](./kubernetes/terraform/kubernetes-training/README.md) For those preferring containerized environments, our Kubernetes solution integrate GPU-Operator and Network-Operator. This setup ensures your training workloads benefit from dedicated GPU resources and optimized network configurations, essential for AI models requiring intense computational power. The inclusion of GPU-Operator simplifies the management of NVIDIA GPUs, automating the deployment of necessary drivers and plugins. Similarly, the Network-Operator enhances network performance, ensuring seamless communication across your cluster. The cluster is designed to leverage InfiniBand technology, offering the fastest host connections for data-intensive tasks. 

[Kubeflow runbook](./kubeflow/README.md) builds on Kubernetes training solution by installing Kubeflow. It integrates kubeflow with Nebius managed services, like Object Storage and MySql cluster.



[Distributed Training with SLURM:](./slurm/slurm-standalone/README.md) For users inclined towards traditional HPC environments, our SLURM solutions offer a streamlined approach. With ready-to-use images that come pre-configured with NVIDIA drivers, these solutions are ideal for those looking to leverage SLURM's powerful job scheduling capabilities. Like our Kubernetes offerings, the SLURM solutions are optimized for InfiniBand connectivity, ensuring peak performance and efficiency in data transfer and communication between nodes.


## Inference Solutions

This collection is specifically designed to streamline the deployment and management of ML inference environments on Kubernetes, utilizing Terraform as the infrastructure-as-code tool.

[Kubernetes prepared for inference:](./kubernetes/terraform/kubernetes-inference/README.md) If you are using ML Inference servers like TextGenerationInference, vLLM, or even your own containerized application, you can use this solution to effectively scale-out your inference. This Kubernetes runbook creats a Kubernetes managed service and installs Nvidia's GPU-Operator which simplifies the management of NVIDIA GPUs, automating the deployment of necessary drivers and plugins.


[The Triton Inference Server](./nvidia-triton-server/README.md) offers a scalable solution for deploying machine learning models across various frameworks (like TensorFlow, PyTorch, ONNX) with efficiency. It optimizes resource use, ensuring low-latency and high-throughput for both real-time and batch processing, making it ideal for streamlining model deployment in production environments.

[Kubeflow with KServe](./kubeflow/README.md) provides a serverless framework to deploy and manage machine learning models in Kubernetes environments efficiently. It simplifies the complexities of serving models with support for autoscaling, model versioning, and multi-framework integration. Ideal for achieving high-performance inference with minimal overhead, KServe is the go-to choice for streamlined model deployment.

## Storage Solutions

Discover our Shared Storage Solutions for the Cloud: Designed to offer seamless, scalable, and secure data storage across your cloud environments. Whether you're collaborating on large-scale projects, managing extensive data sets, or looking to optimize your cloud infrastructure, our solutions provide a robust foundation for data sharing and storage. With features like real-time synchronization, easy access control, and high redundancy, your data is always available, secure, and in sync.

[NFS Server](./storage/nfs/README.md): For a straightforward approach to network storage, our NFS server solution offers simplicity and reliability, making it ideal for those needing easy access to shared files. 

[GlusterFs](./storage/glusterfs-cluster-ubuntu/README.md) excels in distributed environments, providing a robust and scalable storage option for handling large volumes of data across multiple servers seamlessly.


## RAG Solutions
[RAG (Retrieval-Augmented Generation) Generative AI Solution](./generative-ai-examples/nvidia-playground/README.md) based on Nvidia technologies: a blend of language models and data retrieval that elevates AI-generated text to new levels of relevance and precision. This solution is crafted for a wide array of applications, from enhancing customer support to streamlining content creation. By integrating detailed data retrieval with the generative capabilities of AI, it ensures responses are not only accurate but also deeply contextual


## End to end solutions

[Our end-to-end solution with Kubeflow](./kubeflow/README.md) streamlines the machine learning workflow from concept to production on Kubernetes, offering a comprehensive toolkit for building, deploying, and managing scalable ML models. By leveraging Kubeflow, we provide an integrated platform that simplifies the complexities of orchestrating machine learning pipelines, ensuring seamless model training, tuning, and deployment. This approach not only accelerates the development cycle but also enhances model reliability and performance in production environments, empowering businesses to harness the full potential of their data with greater efficiency and precision.



---
## Prerequisites
These samples use mainly [Terraform](https://www.terraform.io/) to deploy architectures on Nebius AI Cloud. For detailed documentation on how to work with Terraform and Nebius AI, please refer to our [documentation](https://nebius.ai/docs/terraform/).

To access Nebius AI API, you will need to install the [Nebius AI CLI](https://nebius.ai/docs/cli/)