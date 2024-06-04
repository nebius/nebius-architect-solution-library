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

variable "segment_ip_addr" {
  type        = string
  description = "IP address for SLURM segment"
  default     = "192.168.10.0/24"
}

variable "cluster_nodes_count" {
  type        = number
  description = "Amount of slurm nodes"
}

variable "sshkey" {
  type        = string
  description = "Public SSH key"
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

variable "filestore" {
  type        = bool
  description = "Use shared managed FileStorage mounted on /mnt/slurm on every worker node"
  default     = true
}

variable "nfs" {
  type        = bool
  description = "Use shared NFS server mounted on /mnt/slurm on every worker node"
  default     = false
}

variable "gluster" {
  type        = bool
  description = "Use shared GlusterFS cluster mounted on /mnt/slurm on every worker node"
  default     = false
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