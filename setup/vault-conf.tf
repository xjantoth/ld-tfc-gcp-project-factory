# Vault configuration
resource "time_sleep" "this" {
  create_duration = "60s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    credentials = base64decode(module.vault.key.private_key)
    description = "Terraform Cloud JWT auth backend"
    name        = "jwt-tfc_demo_gcp_gcs"
  }
}

resource "vault_gcp_secret_backend" "this" {
  namespace   = "root"
  path        = var.secret_engine_name
  credentials = resource.time_sleep.this.triggers["credentials"]
  # credentials = base64decode(module.vault.key.private_key)
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

resource "vault_jwt_auth_backend" "jwt" {
  description = resource.time_sleep.this.triggers["description"]
  # description        = "Terraform Cloud JWT auth backend"
  path               = "jwt"
  oidc_discovery_url = var.tfc_address #
  bound_issuer       = var.tfc_address #
  # oidc_discovery_ca_pem = file("app.terraform.io.cer")
  default_role = "tfc_vault_config"
}

resource "vault_policy" "policies" {
  namespace = "root"
  name      = resource.time_sleep.this.triggers["name"]
  policy    = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Demo
path "${var.secret_engine_name}/static-account/${split("@", module.impersonator.email)[0]}/*"
{
  capabilities = ["read", "list"]
}
EOT
}


resource "vault_jwt_auth_backend_role" "demo_role" {

  backend = vault_jwt_auth_backend.jwt.path

  role_name         = var.vault_jwt_role_name
  token_policies    = ["jwt-tfc_demo_gcp_gcs"]
  user_claim        = "terraform_full_workspace"
  role_type         = "jwt"
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  token_ttl         = 1200

  bound_claims = {
    sub = "organization:${var.tfe_organization}:project:${var.tfe_project}:*"
  }
}
