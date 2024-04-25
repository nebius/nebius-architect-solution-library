output "kube_cluster_id" {
  description = "Kubernetes cluster ID."
  value       = try(module.kube.cluster_id, null)
}

output "kube_cluster_name" {
  description = "Kubernetes cluster name."
  value       = try(module.kube.cluster_name, null)
}

output "external_cluster_cmd_str" {
  description = "Connection string to external Kubernetes cluster."
  value       = try(module.kube.external_cluster_cmd, null)
}

output "internal_cluster_cmd_str" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube.internal_cluster_cmd, null)
}

output "network_id" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(nebius_vpc_network.k8s-network.id, null)
}


output "subnet_id" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(nebius_vpc_subnet.k8s-subnet.id, null)
}


output "kube_external_v4_endpoint" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube.external_v4_endpoint, null)
}

output "kube_cluster_ca_certificate" {
  description = "Connection string to internal Kubernetes cluster."
  value       = try(module.kube.cluster_ca_certificate, null)
}




