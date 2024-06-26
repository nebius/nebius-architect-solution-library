# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}

variable "region" {
  description = "The ID of the zone."
  type        = string
  default     = "eu-north1-c"
}

variable "platform_id" {
  type    = string
  default = "gpu-h100"
}

variable "disk_size" {
  type    = number
  default = 40
}

variable "block_size" {
  type    = number
  default = 32768
}

variable "node_count" {
  type    = number
  default = 2
}

variable "k8s_subnet_CIDR" {
  description = "IP address space for k8s subnet."
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

variable "helm_path" {
  type    = string
  default = "./mount-filesystem"
}

variable "bastion" {
  type    = bool
  default = true
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
