# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
}

variable "namespace" {
  type    = string
  default = "o11y"
}

resource "random_string" "loki_unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

variable "o11y" {
  type = object({
    grafana = optional(bool, true),
    loki    = optional(bool, true),
    prometheus = optional(object({
      enabled       = optional(bool, true),
      node_exporter = optional(bool, true),
    }), {})
    dcgm = optional(object({
      enabled = optional(bool, true),
      node_groups = optional(map(object({
        gpus              = number
        instance_group_id = string
      })), {})
    }), {})
  })
  description = "Configuration of observability stack."
  default     = {}
}
