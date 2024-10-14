# Executor SA
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
  iam_project_roles = {
    (var.project_id) = [
      "roles/storage.admin"
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

# Vault configuration
resource "vault_gcp_secret_backend" "this" {
  namespace                 = "root"
  path                      = var.secret_engine_name
  credentials               = base64decode(module.vault.key.private_key)
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.max_lease_ttl_seconds

  depends_on = [
    module.vault
  ]
}

resource "vault_gcp_secret_static_account" "this" {
  backend               = vault_gcp_secret_backend.this.path
  static_account        = split("@", module.impersonator.email)[0]
  secret_type           = "service_account_key"
  token_scopes          = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account_email = module.impersonator.email

  depends_on = [
    vault_gcp_secret_backend.this
  ]
}

# Terraform Cloud

resource "tfe_organization" "this" {
  name  = "demo-meetup-org"
  email = var.tfe_org_email
}

resource "tfe_oauth_client" "this" {
  organization     = tfe_organization.this.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.vcs_github_token
  service_provider = "github"
}

# Will create a module in Terraform Cloud registry
resource "tfe_registry_module" "this" {

  vcs_repo {
    display_identifier = var.vcs_tf_module
    identifier         = var.vcs_tf_module
    oauth_token_id     = tfe_oauth_client.this.oauth_token_id
    tags               = true
  }
}

resource "tfe_project" "this" {
  organization = tfe_organization.this.name
  name         = "demo-project"
}

resource "tfe_variable_set" "this" {
  for_each     = var.variable_sets
  name         = each.key
  global       = each.value.global
  description  = each.value.description
  organization = tfe_organization.this.name
}

locals {
  tf_variables = flatten([for k, v in var.variable_sets : [for kk, vv in v.variables : {
    "category" : vv.category,
    "description" : vv.description,
    "value" : vv.value,
    "name" : kk,
    "variable_set" : k,
    "hcl" : vv.hcl,
    "sensitive" : vv.sensitive,
    "variable_set_id" : tfe_variable_set.this[k].id
  }]])
}

resource "tfe_variable" "this" {
  for_each        = { for k, v in local.tf_variables : "${v.variable_set}_${v.name}" => v }
  key             = each.value.name
  value           = each.value.value
  category        = each.value.category
  description     = each.value.description
  hcl             = each.value.hcl
  sensitive       = each.value.sensitive
  variable_set_id = each.value.variable_set_id
}

# associate variable_sets with Terraform project
resource "tfe_project_variable_set" "test" {
  for_each        = { for k, v in tfe_variable_set.this : k => v.id }
  project_id      = tfe_project.this.id
  variable_set_id = each.value
}

resource "tfe_workspace" "this" {
  name              = "demo-ws"
  description       = "GCP Demo workspace."
  project_id        = tfe_project.this.id
  organization      = tfe_organization.this.name
  queue_all_runs    = true
  terraform_version = "1.8.3"
  working_directory = "tf-demo-code"
  vcs_repo {
    branch         = "main"
    identifier     = "xjantoth/demo-tf-vault-gcp"
    oauth_token_id = tfe_oauth_client.this.oauth_token_id
  }
}
