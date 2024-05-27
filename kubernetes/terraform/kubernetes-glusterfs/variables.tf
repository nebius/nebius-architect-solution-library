# GlusterFS cluster parameters
variable "storage_nodes" {
  type        = number
  default     = 3
  description = "Number of storage nodes"
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "Disk size GB"
}

variable "ssh_pubkey" {
  type        = string
  default     = ""
  description = "SSH public key to access the cluster nodes"
}

# K8s cluster parameters
variable "cpu_nodes_count" {
  type        = number
  description = "Amount of slurm nodes"
  default     = 3
}

variable "gpu_nodes_count" {
  type        = number
  description = "Amount of slurm nodes"
  default     = 2
}

variable "platform_id" {
  type    = string
  default = "gpu-h100"
}

variable "glusterfs_mount_host_path" {
  type    = string
  default = "/shared"
}