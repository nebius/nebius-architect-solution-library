variable "folder_id" {
  type        = string
  description = "Id of the folder where the resources going to be created"
}

variable "ib_image_id" {
  type        = string
  description = "ID of Infiniband image"
  default     = "arljjqhufbo9rrjsonm2"
}

variable "region" {
  type        = string
  description = "Availability Zone"
  default     = "eu-north1-c"
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
  default     = "gpu-h100-b"
}


variable "mysql_jobs_backend" {
  type        = bool
  description = "Use MySQL for jobs logging in slurm: 1 or 0"
  default     = true
}

