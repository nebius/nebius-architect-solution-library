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

variable "gpu_min_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default     = 1
}

variable "gpu_max_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default     = 5
}


variable "gpu_initial_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default     = 1
}

variable "platform_id" {
  type    = string
  default = "gpu-h100"
}

variable "gpu_env" {
  type    = string
  default = "runc_drivers_cuda"
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
