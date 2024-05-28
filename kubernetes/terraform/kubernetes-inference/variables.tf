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
  type        = list
  default     = ["192.168.10.0/24"]
}

variable "gpu_min_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default = 1
}

variable "gpu_max_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default = 5
}


variable "gpu_initial_nodes_count" {
  type        = number
  description = "Amount of nodes"
  default = 1
}

variable "platform_id" {
  type        = string
  default = "gpu-h100"
}

variable "gpu_env" {
  type        = string
  default = "runc_drivers_cuda"
}
