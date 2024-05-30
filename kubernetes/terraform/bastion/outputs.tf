
output "bastion_ip" {
  value = nebius_vpc_address.bastion-ip.external_ipv4_address[0].address
}
