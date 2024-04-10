variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "image_id" {
  type        = string
  description = "Ubuntu 22.04 LTS"
  default     = "arl390lhup87ofmsg8mc"
}

variable "region" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
}

variable "instance_name" {
  type        = string
  description = "Instance name for the nfs server."
  default     = "nfs-share"
}

variable "username" {
  type        = string
  description = "Username for ssh"
  default     = "user"
}

variable "sshkey" {
  type        = string
  description = "Public SSH key"
}

variable "nfs_path" {
  type        = string
  description = "Path to nfs_device"
  default     = "/nfs"
}

variable "nfs_ip_range" {
  type        = string
  description = "Ip range from where NFS will be available"
}

variable "mtu_size" {
  type        = string
  description = "MTU size to make network fater"
  default     = "8910"
}

variable "nfs_size" {
  type        = string
  description = "Size of the NFS in GB, should be divisbile by 93"
}


variable "subnet_id" {
  type        = string
  description = "Id of the subnet where the NFS share going to be created"
}
