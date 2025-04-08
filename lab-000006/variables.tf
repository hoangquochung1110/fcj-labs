variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "snapshot_identifier" {
  description = "The snapshot identifier to restore from. Leave empty for fresh instance."
  type        = string
  default     = null
}