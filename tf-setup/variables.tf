variable "project_id" {
  type        = string
  description = "Demo GCP project_id"
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

variable "secret_engine_name" {
  description = "Vault GCP secret engine name."
  type        = string
}

variable "default_lease_ttl_seconds" {
  description = "Vault default lease in seconds."
  type        = number
}

variable "max_lease_ttl_seconds" {
  description = "Vault max ttl lease in seconds."
  type        = number
}

variable "tfe_host" {
  description = "Terrafrom Cloud host."
  type        = string
}

variable "tfe_token" {
  description = "Terrafrom Cloud token."
  type        = string
}

variable "vcs_github_token" {
  description = "Github OAUTH token."
  type        = string
}

variable "tfe_org_email" {
  description = "Github OAUTH token."
  type        = string
}

variable "vcs_tf_module" {
  description = "Github module path e.g. xjantoth/terraform-gcp-demo-module"
  type        = string
}

variable "variable_sets" {
  description = "Organisation variable sets"
  type = map(object({
    global      = optional(bool, false)
    description = optional(string, "")
    workspaces  = optional(list(string), [])
    variables = map(object({
      value       = string
      category    = optional(string, "terraform")
      description = optional(string, null)
      hcl         = optional(bool, false)
      sensitive   = optional(bool, false)
    }))
  }))
  default = {}
}

variable "source_ranges" {
  type        = list(string)
  description = "Allowed source ranges for Vault instance."
}

variable "VAULT_PROJECT_ID" {
  type        = string
  description = "GCP project where Vault will be deployed."
}

variable "tfc_address" {
  type        = string
  description = "Terraform Cloud address."
}
