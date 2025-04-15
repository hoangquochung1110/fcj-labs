variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
} 

variable "project_name" {
    description = "project name"
    type = string
    default = "lab35"
}
