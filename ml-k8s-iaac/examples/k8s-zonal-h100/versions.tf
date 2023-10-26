terraform {
  required_version = ">= 1.0.0"

  required_providers {
    nebius = {
      source  = "nebius/nebius"
      version = "0.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 3.3"
    }
  }
}

provider "nebius" {
  endpoint = "api.nemax.nebius.cloud:443"
  folder_id = "bjer0eu4okh6vntopouq"
}


provider "local" {}

provider "random" {}
