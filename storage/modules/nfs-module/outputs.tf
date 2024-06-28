output "nfs_server_internal_ip" {
  description = "The internal IP address to access the NFS server"
  value       = nebius_compute_instance.nfs_server.network_interface.0.ip_address
}

output "nfs_server_external_ip" {
  description = "The external IP address to access the NFS server"
  value       = nebius_compute_instance.nfs_server.network_interface.0.nat_ip_address
}