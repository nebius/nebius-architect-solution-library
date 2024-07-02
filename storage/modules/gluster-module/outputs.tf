output "glusterfs-host"{
  value = nebius_compute_instance.storage_node[0].hostname
}