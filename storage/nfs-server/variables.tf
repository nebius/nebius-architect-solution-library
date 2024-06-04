variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "zone" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
}

variable "username" {
  type        = string
  description = "Username for ssh"
  default     = "storage"
}

variable "sshkey" {
  type        = string
  description = "Public SSH key"
}

variable "nfs_ip_range" {
  type        = string
  description = "Ip range from where NFS will be available"
  default     = "10.0.0.0/8"
}

variable "nfs_size" {
  type        = string
  description = "Size of the NFS in GB, should be divisbile by 93"
  default     = 930
}

variable "subnet_id" {
  type        = string
  description = "Id of the subnet where the NFS share going to be created"
}
