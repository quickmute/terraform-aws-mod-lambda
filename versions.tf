terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.60.0"
    }
  }
  required_version = ">= 1.3"
}