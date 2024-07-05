variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "zone" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
}

variable "ib_fabric" {
  type        = string
  description = "InfiniBand fabric. Should be fabric-4 for h100-type-c, fabric-1 for other types"
  default     = "fabric-4"
}

variable "ipv4_range" {
  type        = string
  description = "IP address for SLURM segment"
  default     = "172.16.0.0/16"
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
  description = "Platform type for GPU nodes"
  default     = "gpu-h100-c"
}

variable "mysql_accounting_backend" {
  type        = bool
  description = "Use MySQL for accounting in slurm: true or false"
  default     = false
}

variable "shared_fs_type" {
  type        = string
  description = "Use shared managed FileStorage mounted on /mnt/slurm on every worker node"
  default     = "none"
  validation {
    condition     = var.shared_fs_type == "none" ? true : contains(["nfs", "gluster", "filestore"], var.shared_fs_type)
    error_message = "shared_fs_type must be one of: nfs, gluster, filestore"
  }
}

variable "gluster_disk_size" {
  type        = number
  description = "Size of disk per each Gluster node x930"
  default     = 930
}

variable "gluster_disks_per_vm" {
  type        = number
  description = "Number of disks/bricks per gluster VM node"
  default     = 1
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

variable "node_name_prefix" {
  type        = string
  description = "Slurm node name prefix"
  default     = "slurm-node"
}

variable "slurm_version" {
  type        = string
  description = "Slurm version"
  default     = "24.05.1"
}

variable "enroot_version" {
  type        = string
  description = "Enroot version"
  default     = "3.5.0"
}
