terraform {
  required_version = ">= 1.14"

  cloud {
    organization = "CloudIX"
    hostname     = "app.terraform.io"

    workspaces {
      name = "tf-vcs-compute"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
