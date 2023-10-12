terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.8"
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

provider "yandex" {
  endpoint = "api.nemax.nebius.cloud:443"
  folder_id = "bjer0eu4okh6vntopouq"
}


provider "local" {}

provider "random" {}
