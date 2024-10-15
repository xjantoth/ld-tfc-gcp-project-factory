provider "google" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

provider "google-beta" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

variable "project_id" {
  type        = string
  description = "Project ID to list buckets in"
}

data "google_storage_buckets" "this" {
  project = var.project_id
}

output "buckets" {
  value = data.google_storage_buckets.this.buckets
}
