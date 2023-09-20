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
  token="t1.9euamseVjJKNnZzKncySlpLIk86LjO3rmprHlYySjZ2cyp3Li5iNmsqSjYzl8_c8OlVX-e9WSyhs_t3z93xoUlf571ZLKGz-zef165qax5WMko2dnMqXi5uLkMbLjJGX7_zF65qax5WMko2dnMqXi5uLkMbLjJGXveuamseVjJKNnZzKipHNmp7Jm8aZibXrhpzRlp6S0ZCPmpGWm9KMmo2Jmo0.aKH3i-dyKCFLC0zhmR1OuKkBAxEhIZWmiVqjHTd-3WIFXUmTZpxek8HEQ78NKPy_PNDmoFTZHmRBh_v6cBabBg"
}


provider "local" {}

provider "random" {}
