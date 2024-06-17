variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "zone_id" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
}

variable "storage_nodes" {
  type        = number
  default     = 3
  description = "Number of storage nodes"
}

# DISK OPTIONS

variable "disk_count_per_vm" {
  type        = number
  default     = 2
  description = "Number disks for GlusterFS per VM"
}

variable "disk_type" {
  type        = string
  # network-ssd-io-m3 # network-ssd-nonreplicated # network-ssd
  default     = "network-ssd"
  description = "Type of GlusterFS disk"
}

variable "disk_size" {
  type        = number
  default     = 930
  description = "Disk size GB"
}

variable "disk_block_size" {
  type        = number
  default     = 4096
  description = "Disk block size"
}

# STORAGE VM RESOURCES

variable "storage_cpu_count" {
  type        = number
  default     = 8
  description = "Number of CPU in Storage Node"
}

variable "storage_memory_count" {
  type        = number
  default     = 8
  description = "RAM (GB) size in Storage Node"
}

# SSH KEY

variable "ssh_pubkey" {
  type        = string
  description = "SSH public key to access the cluster nodes"
}