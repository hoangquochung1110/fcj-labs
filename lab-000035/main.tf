terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    local = {
        source = "hashicorp/local"
        version = "~> 2.5.2"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# This should be at the top level, not inside another resource
data "http" "tracks_list" {
  url = "https://raw.githubusercontent.com/AWS-First-Cloud-Journey/Lab-000035-DataLake-on-AWS/master/tracks_list.json"
}