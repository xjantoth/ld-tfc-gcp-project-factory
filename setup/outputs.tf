output "ssh" {
  description = "SSH command copy/paste."
  value       = "ssh -i demo ${local.user}@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}

output "tunnel" {
  description = "SSH command copy/paste."
  value       = "ssh -L 8080:127.0.0.1:8200 -i demo ${local.user}@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}

output "browser_public" {
  description = "Browser URL public"
  value       = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:8200"
}

output "browser_tunnel" {
  description = "Browser URL tunnel"
  value       = "http://127.0.0.1:8200"
}

output "VAULT_TOKEN" {
  value     = resource.random_string.this.result
  sensitive = true
}
