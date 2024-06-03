terraform {
  required_version = ">= 1.0.0"

  required_providers {
    nebius = {
      source  = "terraform-registry.storage.ai.nebius.cloud/nebius/nebius"
      version = ">= 0.9.0"
    }
  }
}
