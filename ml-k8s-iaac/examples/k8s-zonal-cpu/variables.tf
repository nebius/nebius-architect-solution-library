# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}

variable "network_id" {
  description = "The ID of the cluster network."
  type        = string
}


variable "subnet_id" {
  description = "The ID of the cluster network."
  type        = string
}





