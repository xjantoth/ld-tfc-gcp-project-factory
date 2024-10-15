# check "health_check" {
#   data "http" "vault" {
#     url = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:8200"
#   }

#   assert {
#     condition = data.http.vault.status_code == 200
#     error_message = "${data.http.vault.url} returned an unhealthy status code"
#   }
# }

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

resource "vault_jwt_auth_backend" "jwt" {
  description        = "Terraform Cloud JWT auth backend"
  path               = "jwt"
  oidc_discovery_url = var.tfc_address #
  bound_issuer       = var.tfc_address #
  # oidc_discovery_ca_pem = file("app.terraform.io.cer")
  default_role = "tfc_vault_config"
}

resource "vault_policy" "policies" {
  namespace = "root"
  name      = "jwt-tfc_demo_gcp_gcs"
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
path "gcp-demo/static-account/demo-impersonator-0/*"
{
  capabilities = ["read", "list"]
}
EOT
}


resource "vault_jwt_auth_backend_role" "demo_role" {

  backend = vault_jwt_auth_backend.jwt.path

  role_name         = "role-gcp-demo-tfe-vault"
  token_policies    = ["jwt-tfc_demo_gcp_gcs"]
  user_claim        = "terraform_full_workspace"
  role_type         = "jwt"
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  token_ttl         = 1200

  bound_claims = {
    sub = "organization:demo-meetup-org:project:demo-project:*"
  }
}
