module gluster-module {
  providers = {
    nebius = nebius
  }
  source = "../modules/gluster-module"
  folder_id = var.folder_id
  ssh_pubkey = var.ssh_pubkey
  is_standalone = true
}