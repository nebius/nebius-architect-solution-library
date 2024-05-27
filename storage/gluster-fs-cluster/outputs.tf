output "net" {
  value = nebius_vpc_network.default
}

output "subnet" {
  value = nebius_vpc_subnet.default
}

output "glusterfs-host"{
  value = nebius_compute_instance.storage_node[0].hostname
}