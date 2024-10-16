# Executor SA

data "google_organization" "org" {
  domain = "devopsinuse.sk"
}

module "executor" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v34.1.0"
  project_id  = var.project_id
  name        = "executor-0"
  description = "Terraform Executor service account."
  prefix      = var.prefix
  # authoritative roles granted *on* the service accounts to other identities
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [module.impersonator.iam_email]
  }
  # non-authoritative roles granted *to* the service accounts on other resources
  iam_organization_roles = {
    (data.google_organization.org.org_id) = [
      "roles/resourcemanager.folderAdmin",
      "roles/resourcemanager.projectCreator",
      "roles/resourcemanager.tagUser",
      "roles/billing.admin"
    ]
  }
}

# Impersonator SA
module "impersonator" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v34.1.0"
  project_id  = var.project_id
  name        = "impersonator-0"
  description = "Terraform Impersonator service account."
  prefix      = var.prefix
  iam = {
    "roles/iam.serviceAccountKeyAdmin" = [module.vault.iam_email]
  }
}

# Vault SA
# Generates temporary credentials file for impersonator SA
module "vault" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v34.1.0"
  project_id  = var.project_id
  name        = "vault-0"
  description = "Terraform Vault service account."
  prefix      = var.prefix

  generate_key = true
}
