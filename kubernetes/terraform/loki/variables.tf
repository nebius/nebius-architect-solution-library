# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}


variable "kube_external_v4_endpoint" {
  description = "Connection string to internal Kubernetes cluster."
}

variable "kube_cluster_ca_certificate" {
  description = "Connection string to internal Kubernetes cluster."
}


resource "random_string" "loki_unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}