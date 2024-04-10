# resource "local_file" "slurm-inventory" {
#   content  = templatefile(
#       "${path.module}/files/inventory.tpl", {
#         is_mysql    = var.mysql_jobs_backend
#         master      = "${nebius_compute_instance.master.network_interface.0.nat_ip_address} ansible_user=slurm"
#         nodes       = join("\n", [for node in nebius_compute_instance.slurm-node: "${node.network_interface.0.nat_ip_address} ansible_user=slurm"])
#       })
#   filename = "./inventory.yaml"
# }

