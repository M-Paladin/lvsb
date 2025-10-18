terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.85.0"
    }
  }
}

# https://registry.terraform.io/providers/bpg/proxmox/latest/docs

provider "proxmox" {
  #  endpoint = "https://192.168.0.11:8006/"
  #  api_token = var.api_token
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  ssh {
    agent = true
    #  username = "root"
  }
}
