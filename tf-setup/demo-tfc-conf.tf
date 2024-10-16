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
  working_directory = "project-factory"
  vcs_repo {
    branch         = "main"
    identifier     = "xjantoth/demo-tf-vault-gcp"
    oauth_token_id = tfe_oauth_client.this.oauth_token_id
  }
}
