# Security Stack Container Definitions
# SWAG, Wireguard, Vaultwarden, RustDesk

locals {
  # Security-specific mount points
  security_mounts = [
    {
      key     = "mp0"
      slot    = 0
      storage = var.shared_data_storage
      mp      = "/data"
      size    = "10T"
    },
    {
      key     = "mp1"
      slot    = 1
      storage = var.docker_storage
      mp      = "/docker"
      size    = "128G"
    }
  ]
}

# SWAG Reverse Proxy (Container 100)
module "swag" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 100
  hostname    = "SWAG"
  
  # Resources
  memory    = 1024
  cores     = 2
  disk_size = "4G"
  swap      = 512
  
  # Template - Ubuntu 25.04 (Bleeding edge)
  template = "ubuntu-25.04-standard_25.04-1_amd64.tar.zst"
  ostype   = "ubuntu"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features
  features = {
    nesting = true
    mount   = ""
  }
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.3/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "security"
  tags            = ["reverse-proxy", "ssl", "nginx", "letsencrypt"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "HTTP"
      dest    = ""
      dport   = "80"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "HTTPS"
      dest    = ""
      dport   = "443"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Wireguard VPN Server (Container 116)
module "wireguard" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 116
  hostname    = "wireguard"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "7G"
  swap      = 2048
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features
  features = {
    nesting = true
    mount   = ""
  }
  
  # Dual Network - Primary + VPN Gateway
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.219/24"
      gw       = var.primary_gateway
      firewall = true
    },
    {
      name     = "eth1"
      bridge   = "vmbr1"
      ip       = "10.10.10.1/24"
      gw       = ""
      firewall = true
    }
  ]
  
  # Organization
  service_category = "security"
  tags            = ["vpn", "wireguard", "dual-network", "gateway"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "WireGuard VPN"
      dest    = ""
      dport   = "51820"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "udp"
      source  = ""
      sport   = ""
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "VPN Network Traffic"
      dest    = ""
      dport   = ""
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = ""
      source  = "10.10.10.0/24"
      sport   = ""
    },
    {
      type    = "out"
      action  = "ACCEPT"
      comment = "VPN Network Traffic"
      dest    = "10.10.10.0/24"
      dport   = ""
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = ""
      source  = ""
      sport   = ""
    }
  ]
}

# Vaultwarden Password Manager (Container 104)
module "vaultwarden" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 104
  hostname    = "alpine-vaultwarden"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "4G"
  swap      = 1024
  
  # Template - Alpine 3.22.1
  template = "alpine-3.22-default_20240606_amd64.tar.xz"
  ostype   = "alpine"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.security_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.248/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "security"
  tags            = ["password-manager", "bitwarden", "alpine"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Vaultwarden WebUI"
      dest    = ""
      dport   = "8080"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# RustDesk Remote Desktop Server (Container 103)
module "rustdeskserver" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 103
  hostname    = "rustdeskserver"
  
  # Resources
  memory    = 512
  cores     = 1
  disk_size = "2G"
  swap      = 256
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features
  features = {
    nesting = true
    mount   = ""
  }
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.140/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "security"
  tags            = ["remote-desktop", "rustdesk", "self-hosted"]
  
  # Firewall
  enable_firewall = false
}