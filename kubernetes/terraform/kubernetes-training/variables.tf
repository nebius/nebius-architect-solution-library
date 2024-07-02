# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}

variable "zone_id" {
  description = "The ID of the zone."
  type        = string
  default     = "eu-north1-c"
}

variable "k8s_subnet_CIDR" {
  description = "IP address space for k8s subnet."
  type        = list(any)
  default     = ["192.168.10.0/24"]
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

variable "ssh_username" {
  description = "Username for SSH login"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Public SSH key to access the cluster nodes"
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Path to a SSH public key to access the cluster nodes"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "gpu_cluster" {
  description = "Gpu cluster name"
  type        = string
  default     = "fabric-1"
}

variable "o11y" {
  type = object({
    grafana = optional(bool, true),
    loki    = optional(bool, true),
    prometheus = optional(object({
      enabled       = optional(bool, true),
      node_exporter = optional(bool, true),
    }), {})
    dcgm = optional(object({
      enabled = optional(bool, true),
      node_groups = optional(map(object({
        gpus              = number
        instance_group_id = string
      })), {})
    }), {})
  })
  description = "Configuration of observability stack."
  default     = {}
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

variable "glusterfs_mount_host_path" {
  type    = string
  default = "/shared"
}

variable "shared_fs_type" {
  type        = string
  description = "Use shared managed FileStorage mounted on /mnt/slurm on every worker node"
  default     = "none"
  validation {
    condition     = var.shared_fs_type == "none" ? true : contains(["gluster", "filestore"], var.shared_fs_type)
    error_message = "shared_fs_type must be one of: gluster, filestore"
  }
}