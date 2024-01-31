output "public_ip" {
  value = nebius_compute_instance.client_node_a[0].network_interface[0].nat_ip_address
}

output "connect_line" {
  value = "ssh storage@${nebius_compute_instance.client_node_a[0].network_interface[0].nat_ip_address}"
}
