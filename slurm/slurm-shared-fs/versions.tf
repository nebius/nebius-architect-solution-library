terraform {
  required_version = ">= 1.0.0"

  required_providers {
    nebius = {
      source = "terraform-registry.storage.ai.nebius.cloud/nebius/nebius"
      version = ">= 0.11.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "nebius" {}