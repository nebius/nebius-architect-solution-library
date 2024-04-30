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
  type        = string
  default = "gpu-h100"
}

variable "disk_size" {
  type        = number
  default     = 4000
}


variable "block_size" {
  type        = number
  default     = 32768
}


variable "node_count" {
  type        = number
  default     = 2
}


variable "helm_path" {
  type        = string
  default     = "./mount-filesystem"
}
