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

# NUMBER OF VMs PER ZONE

variable "storage_node_per_zone" {
  type        = number
  default     = 3
  description = "Number of storage node per zone"
}

# DISK OPTIONS

variable "disk_count_per_vm" {
  type        = number
  default     = 1
  description = "Number of additional disks for GlusterFS in each zone"
}

variable "disk_type" {
  type        = string
  # network-ssd-io-m3 # network-ssd-nonreplicated # network-ssd
  default     = "network-ssd"
  description = "Type of GlusterFS disk"
}

variable "disk_size" {
  type        = number
  default     = 1024
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

variable "local_pubkey_path" {
  type        = string
  default     = "../../id_key.pub"
  description = "Local public key to access the client"
}

# TYPE: ZONAL (better for performance) OR REGIONAL (for HA)

variable "is_ha" {
  type    = bool
  default = false
}
