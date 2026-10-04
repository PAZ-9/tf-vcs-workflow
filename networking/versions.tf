terraform {
  required_version = ">= 1.14"

  cloud {
    organization = "CloudIX"
    hostname     = "app.terraform.io"

    workspaces {
      name = "tf-vcs-networking"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
    }
  }
}

provider "aws" {
  region = var.region
}
