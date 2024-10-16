provider "google" {}

provider "google" {
  project = var.VAULT_PROJECT_ID
  alias   = "vault"
}

provider "google-beta" {}

provider "tfe" {
  hostname = var.tfe_host
  token    = var.tfe_token
}

provider "vault" {
  token   = random_string.this.result
  address = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:8200"
}
