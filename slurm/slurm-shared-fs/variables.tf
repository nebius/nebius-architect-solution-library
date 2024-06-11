variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "ib_image_id" {
  type        = string
  description = "ID of Infiniband image"
  default     = "arljjqhufbo9rrjsonm2"
}

variable "zone" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
}

variable "ipv4_range" {
  type        = string
  description = "IP address for SLURM segment"
  default     = "192.168.10.0/24"
}

variable "cluster_nodes_count" {
  type        = number
  description = "Amount of slurm nodes"
}

variable "ssh_public_key" {
  description = "SSH Public Key to access the cluster nodes"
  type = object({
    key  = optional(string),
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}
  validation {
    condition     = var.ssh_public_key.key != null || fileexists(var.ssh_public_key.path)
    error_message = "SSH Public Key must be set by `key` or file `path` ${var.ssh_public_key.path}"
  }
}

variable "platform_id" {
  type        = string
  description = "Platform for nodes: gpu-h100-b for Inspur or gpu-h100 for Gigabyte"
  default     = "gpu-h100"
}

variable "mysql_accounting_backend" {
  type        = bool
  description = "Use MySQL for accounting in slurm: true or false"
  default     = false
}

variable "shared_fs_type" {
  type        = string
  description = "Use shared managed FileStorage mounted on /mnt/slurm on every worker node"
  default     = null
  validation {
    condition     = var.shared_fs_type == null ? true : contains(["nfs", "gluster", "filestore"], var.shared_fs_type)
    error_message = "shared_fs_type must be one of: nfs, gluster, filestore"
  }
}

variable "gluster_disk_size" {
  type        = number
  description = "Size of disk per each Gluster node x930"
  default     = 930
}

variable "gluster_nodes" {
  type        = number
  description = "Number of Gluster nodes in cluster"
  default     = 3
}

variable "fs_size" {
  type        = number
  description = "Shared FileStorage or NFS size x930"
  default     = "930"
}
