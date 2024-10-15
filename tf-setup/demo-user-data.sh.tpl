#!/bin/sh
set -e

# https://blog.nishanthkp.com/docs/devsecops/sm/vault/install-vault-in-unix-and-mac/
sudo apt update
sudo apt-get install software-properties-common -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault
IPv4=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
vault server -dev -dev-root-token-id="${VAULT_TOKEN}" -dev-listen-address=$${IPv4}:8200 &
