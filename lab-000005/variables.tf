variable "vpc_cidr_block" {
  description = "The primary IPv4 CIDR block for the entire VPC."
  type        = string
}

variable "vpc_name" {
  description = "A name tag to easily identify the VPC."
  type        = string
}

variable "availability_zones" {
  description = "A list of Availability Zones where subnets will be created."
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for public subnets, one for each AZ."
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for private subnets, one for each AZ."
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled for instances launched in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether DNS resolution is supported for the VPC."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "A map of tags to apply consistently across all related resources."
  type        = map(string)
  default     = {}
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "snapshot_identifier" {
  description = "The snapshot ID to recover from"
  type        = string
  default     = null  # Optional, so it can be empty
}
