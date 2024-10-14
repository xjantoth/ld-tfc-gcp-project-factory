terraform {
  required_version = ">= 1.8.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.43.1"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.43.1"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.59.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4.0"
    }
  }
}
