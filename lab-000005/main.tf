terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "http" "my_public_ip" {
  url = "https://api.ipify.org"
}

locals {
  ami           = "ami-0b5a4445ada4a59b1"
  instance_type = "t2.micro"
}