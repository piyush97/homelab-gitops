terraform {
  required_version = ">= 1.6"
  
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 3.0"
    }
  }
  
  # Uncomment and configure for remote state management
  # backend "s3" {
  #   bucket = "homelab-terraform-state"
  #   key    = "homelab/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Proxmox Provider Configuration
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_api_user
  pm_password     = var.proxmox_api_password
  pm_tls_insecure = var.proxmox_api_tls_insecure
  
  # Optional: Use API token instead of password
  # pm_api_token_id     = var.proxmox_api_token_id
  # pm_api_token_secret = var.proxmox_api_token_secret
  
  # Connection settings
  pm_timeout = 600
  
  # Logging
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}