# Executor SA
module "executor" {
  source = "../modules/iam-service-account"
  # version     = "30.0.0"
  project_id  = var.project_id
  name        = "nocode-executor-0"
  description = "Terraform Executor service account."
  prefix      = var.prefix
  # authoritative roles granted *on* the service accounts to other identities
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [module.impersonator.iam_email]
  }
  # non-authoritative roles granted *to* the service accounts on other resources
  iam_project_roles = {
    (var.project_id) = [
      "roles/storage.admin"
    ]
  }
}

# Impersonator SA
module "impersonator" {
  source = "../modules/iam-service-account"
  # version     = "30.0.0"
  project_id  = var.project_id
  name        = "nocode-impersonator-0"
  description = "Terraform Impersonator service account."
  prefix      = var.prefix
  iam = {
    "roles/iam.serviceAccountKeyAdmin" = [module.vault.iam_email]
  }
}

# Vault SA
# Generates temporary credentials file for impersonator SA
module "vault" {
  source = "../modules/iam-service-account"
  # version     = "30.0.0"
  project_id  = var.project_id
  name        = "nocode-vault-0"
  description = "Terraform Vault service account."
  prefix      = var.prefix

  generate_key = true
}

output "key" {
  value     = module.vault.key.private_key
  sensitive = true
}
