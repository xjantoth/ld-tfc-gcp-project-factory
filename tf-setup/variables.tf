variable "project_id" {
  type        = string
  description = "Nocode demo GCP project_id"
}

variable "prefix" {
  description = "Prefix applied to service account names."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}
