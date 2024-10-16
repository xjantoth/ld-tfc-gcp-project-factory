provider "google" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

provider "google-beta" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

variable "project_id" {
  type        = string
  description = "Project ID."
}

