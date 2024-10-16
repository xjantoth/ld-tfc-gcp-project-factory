# Terraform Cloud

resource "tfe_organization" "this" {
  name  = var.tfe_organization
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
  name         = var.tfe_project
}

data "google_billing_account" "this" {
  display_name = "My Billing Account"
  open         = true
}

locals {
  variable_sets = {
    vault_oidc : {
      description : "Vault Dynamic Provider Credentials",
      variables : {
        TFC_VAULT_PROVIDER_AUTH : {
          category : "env",
          description : "Enables TFE Vault Provider authentication.",
          value : true
        },
        TFC_VAULT_ADDR : {
          category : "env",
          description : "Address of the Vault instance to authenticate against.",
          value : "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:8200",
        },
        TFC_VAULT_BACKED_GCP_AUTH : {
          category : "env",
          description : "Enables vault backed dynamic credentials with GCP.",
          value : true,
        },
        TFC_VAULT_BACKED_GCP_AUTH_TYPE : {
          category : "env",
          description : "Specifies the type of authentication to perform with GCP.",
          value : "static_account/service_account_key"
        },
        TFC_VAULT_BACKED_GCP_MOUNT_PATH : {
          category : "env",
          description : "The mount path of the GCP secrets engine in Vault.",
          value : var.secret_engine_name
        }
      }
    },
    demo_vars = {
      description : "Vars for DEMO creation",
      variables : {
        TFC_VAULT_BACKED_GCP_RUN_VAULT_STATIC_ACCOUNT : {
          category : "env",
          description : "The name of the static account in Vault.",
          value : split("@", module.impersonator.email)[0]
        },
        TFC_VAULT_RUN_ROLE : {
          category : "env",
          description : "The name of the Vault role to authenticate against",
          value : var.vault_jwt_role_name
        },
        billing_account : {
          category : "terraform",
          description : "Billing Account ID.",
          value : "{\"id\":\"${data.google_billing_account.this.id}\"}",
          hcl : true
        },
        prefix : {
          category : "terraform",
          description : "Factory prefix.",
          value : var.prefix
        }
      }
    }
  }

  tf_variables = flatten([for k, v in local.variable_sets : [for kk, vv in v.variables : {
    "category" : vv.category,
    "description" : vv.description,
    "value" : vv.value,
    "name" : kk,
    "variable_set" : k,
    "hcl" : try(vv.hcl, false),
    "sensitive" : try(vv.sensitive, false),
    "variable_set_id" : tfe_variable_set.this[k].id
  }]])
}

resource "tfe_variable_set" "this" {
  for_each     = local.variable_sets
  name         = each.key
  global       = try(each.value.global, false)
  description  = each.value.description
  organization = tfe_organization.this.name
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
  name              = "${var.prefix}-ws"
  description       = "GCP Demo workspace."
  project_id        = tfe_project.this.id
  organization      = tfe_organization.this.name
  queue_all_runs    = true
  terraform_version = "1.8.3"
  working_directory = var.vcs_working_direcotry
  vcs_repo {
    branch         = var.vcs_branch
    identifier     = var.vcs_identifier
    oauth_token_id = tfe_oauth_client.this.oauth_token_id
  }
}
