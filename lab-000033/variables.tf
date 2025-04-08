variable "app_bucket" {
  description = "Application bucket"
  type        = string
}

variable "athena_bucket" {
  description = "Data store for athena query result"
  type        = string
}

variable "trail" {
  description = "Trail name"
  type = string
}