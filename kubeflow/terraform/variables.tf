# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}

# variable "network_id" {
#   description = "The ID of the cluster network."
#   type        = string
# }


# variable "subnet_id" {
#   description = "The ID of the cluster network."
#   type        = string
# }

variable "region" {
  description = "The ID of the cluster network."
  type        = string
  default     = "eu-north1-c"
}

variable "username" {
  description = "Username."
  type        = string
}


resource "random_string" "kf_unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}