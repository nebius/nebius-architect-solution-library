output "kube_cluster_id" {
  description = "Kubernetes cluster ID."
  value       = try(module.kube-cluster.kube_cluster_id, null)
}

output "kube_cluster_name" {
  description = "Kubernetes cluster name."
  value       = try(module.kube-cluster.kube_cluster_name, null)
}

output "external_cluster_cmd_str" {
  description = "Connection string to external Kubernetes cluster."
  value       = try(module.kube-cluster.external_cluster_cmd_str, null)
}

output "internal_cluster_cmd_str" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube-cluster.internal_cluster_cmd_str, null)
}

output "kube_external_v4_endpoint" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube-cluster.kube_external_v4_endpoint, null)
}

output "kube_cluster_ca_certificate" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube-cluster.kube_cluster_ca_certificate, null)
}


output "network_id" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube-cluster.network_id, null)
}

output "subnet_id" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube-cluster.subnet_id, null)
}

