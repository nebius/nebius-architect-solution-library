variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "zone_id" {
  type        = string
  default     = "eu-north1-c"
  description = "Availability zone"
}

# NETWORKING

variable "network_name" {
  type        = string
  default     = "gfs-network"
  description = "Name of the network"
}

variable "subnet_name" {
  type        = string
  default     = "gfs-network"
  description = "Name of subnet"
}

# NUMBER OF VMs for cluster

variable "storage_nodes" {
  type        = number
  default     = 3
  description = "Number of storage nodes"
}

variable "platform_id" {
  type        = string
  default     = "standard-v2"
  description = "compute platform id for gluster node"
}

# DISK OPTIONS

variable "disk_count_per_vm" {
  type        = number
  default     = 1
  description = "Number disks for GlusterFS per VM"
}

variable "disk_type" {
  type = string
  # network-ssd-io-m3 # network-ssd-nonreplicated # network-ssd
  default     = "network-ssd-io-m3"
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
  default     = 32
  description = "Number of CPU in Storage Node"
}

variable "storage_memory_count" {
  type        = number
  default     = 32
  description = "RAM (GB) size in Storage Node"
}

# SSH KEY

variable "ssh_pubkey" {
  type        = string
  description = "SSH public key to access the cluster nodes"
}

variable "is_standalone" {
  type        = bool
  description = "To run module standalone and create own VPC resources"
  default     = true
}

variable "ext_subnet_id" {
  type        = string
  description = "For external use as module: will use this subnet to pur gluster VMs inside"
  default     = ""
}