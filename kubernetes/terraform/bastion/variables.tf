variable "folder_id" {
  description = "The ID of the folder that the Bastion should be deployed to."
  type        = string
  default     = null
}

variable "bastion_cores" {
  type    = number
  default = 2
}

variable "bastion_memory" {
  type    = number
  default = 4
}

variable "bastion_prefix" {
  type    = string
  default = ""
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

variable "kubernetes_cluster_id" {
  type = string
}

variable "filesystem_id" {
  type = string
}

variable "subnet_id" {
  type = string
}
