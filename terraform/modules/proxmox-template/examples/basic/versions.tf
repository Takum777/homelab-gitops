terraform {
  required_version = ">= 1.9.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.114.0"
    }
  }
}

# Connection comes from PROXMOX_VE_ENDPOINT, PROXMOX_VE_API_TOKEN
# and PROXMOX_VE_INSECURE, see docs/proxmox-setup.md
provider "proxmox" {}
