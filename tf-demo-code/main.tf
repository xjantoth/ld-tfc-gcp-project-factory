provider "google" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

provider "google-beta" {
  impersonate_service_account = "demo-executor-0@mystic-airway-438411-a1.iam.gserviceaccount.com"
}

data "google_storage_buckets" "this" {
  project = "example-project"
}

output "buckets" {
  value = data.google_storage_buckets.this.buckets
}
