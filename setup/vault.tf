locals {
  prefix  = "demo-gcp"
  region  = "europe-west3"
  vm_size = "n2-standard-2"
  user    = "demo"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "demo"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  content         = chomp(tls_private_key.ssh.public_key_openssh)
  filename        = "demo.pub"
  file_permission = "0600"
}

resource "random_string" "this" {
  length  = 32
  lower   = true
  special = false
}

resource "google_compute_network" "this" {
  provider                = google.vault
  name                    = "vpc-${local.prefix}"
  auto_create_subnetworks = false
  mtu                     = 1460
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  provider      = google.vault
  name          = "subnet-${local.prefix}-${local.region}"
  ip_cidr_range = "192.168.0.0/24"
  region        = local.region
  network       = google_compute_network.this.id
  #tfsec:ignore:google-compute-enable-vpc-flow-logs
  stack_type = "IPV4_ONLY"
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "this" {
  provider = google.vault
  name     = "fw-${local.prefix}-${local.region}"
  network  = google_compute_network.this.self_link
  #tfsec:ignore:google-compute-no-public-ingress
  source_ranges = var.source_ranges
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22", "8200"]
  }
}

resource "google_compute_instance" "default" {
  provider = google.vault

  name         = local.prefix
  machine_type = local.vm_size
  zone         = "${local.region}-a"

  tags = [local.prefix, "vm", "gcp", "terraform"]

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = local.prefix
      }
    }
  }
  # when you want to change instance type
  allow_stopping_for_update = true

  network_interface {
    network    = google_compute_network.this.id
    subnetwork = google_compute_subnetwork.this.id

    #tfsec:ignore:google-compute-no-public-ip
    access_config {
      // Ephemeral public IP will be provided
    }
  }

  metadata = {
    block-project-ssh-keys = true
    ssh-keys               = "${local.user}:${chomp(tls_private_key.ssh.public_key_openssh)}"
    startup-script = templatefile(
      "${path.module}/demo-user-data.sh.tpl",
      {
        VAULT_TOKEN = random_string.this.result
    })

  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

}
