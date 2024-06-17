module gluster-module {
  providers = {
    nebius = nebius
  }
  source = "../modules/gluster-module"
  folder_id = var.folder_id
  ssh_pubkey = var.ssh_pubkey
  disk_count_per_vm = var.disk_count_per_vm
  is_standalone = true
}