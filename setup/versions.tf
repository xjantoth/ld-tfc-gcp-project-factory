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

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}
