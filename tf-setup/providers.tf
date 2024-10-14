provider "google" {}

provider "google-beta" {}

provider "tfe" {
  hostname = var.tfe_host
  token    = var.tfe_token
}
