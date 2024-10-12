terraform {
  required_version = ">= 1.8.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.6.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.6.0"
    }

    #    tfe = {
    #      source  = "hashicorp/tfe"
    #      version = ">= 0.56.0"
    #    }
    #
    #    vault = {
    #      source  = "hashicorp/vault"
    #      version = "~> 4.1"
    #    }
  }
}
