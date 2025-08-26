# Business & Storage Stack Container Definitions
# Odoo, Paperless-ngx, Immich, File Server, Docker, ntfy

locals {
  # Business-specific mount points
  business_mounts = [
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
  
  # Large storage mount for file server
  fileserver_mounts = [
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

# Immich Photo Management (Container 105)
module "immich" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 105
  hostname    = "immich"
  
  # Resources
  memory    = 4096
  cores     = 4
  disk_size = "8G"
  swap      = 2048
  
  # Template - Ubuntu 25.04 (Bleeding edge)
  template = "ubuntu-25.04-standard_25.04-1_amd64.tar.zst"
  ostype   = "ubuntu"
  
  # Security - Privileged for GPU passthrough
  privileged = true
  onboot     = true
  
  # Features - GPU access, USB devices
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.business_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.15/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "storage"
  tags            = ["photos", "ai", "gpu-passthrough", "privileged"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Immich WebUI"
      dest    = ""
      dport   = "2283"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Immich Backup Instance (Container 117) - Stopped by default
module "immich_backup" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 117
  hostname    = "immich-backup"
  
  # Resources
  memory    = 9216
  cores     = 4
  disk_size = "8G"
  swap      = 4096
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security - Privileged for GPU passthrough
  privileged = true
  onboot     = false  # Stopped by default
  start_on_create = false
  
  # Features - GPU access
  features = {
    nesting = true
    mount   = ""
  }
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.10/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "storage"
  tags            = ["photos", "backup", "gpu-passthrough", "privileged", "stopped"]
  
  # Firewall
  enable_firewall = false
}

# File Server with Cockpit (Container 102)
module "fileserver" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 102
  hostname    = "fileserver"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "4G"
  swap      = 1024
  
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
  
  # Storage Mounts
  mount_points = local.fileserver_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.5/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "storage"
  tags            = ["nas", "cockpit", "smb", "file-sharing"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Cockpit WebUI"
      dest    = ""
      dport   = "9090"
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
      comment = "SMB/CIFS"
      dest    = ""
      dport   = "445"
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
      comment = "SMB NetBIOS"
      dest    = ""
      dport   = "139,138,137"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp,udp"
      source  = ""
      sport   = ""
    }
  ]
}

# Google Drive (Container 101)
module "drive" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 101
  hostname    = "drive"
  
  # Resources
  memory    = 512
  cores     = 1
  disk_size = "4G"
  swap      = 256
  
  # Template - Alpine 3.22.1
  template = "alpine-3.22-default_20240606_amd64.tar.xz"
  ostype   = "alpine"
  
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
      ip       = "192.168.0.126/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "storage"
  tags            = ["cloud-storage", "google-drive", "alpine"]
  
  # Firewall
  enable_firewall = false
}

# Docker Host (Container 111)
module "docker" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 111
  hostname    = "docker"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "4G"
  swap      = 1024
  
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
      ip       = "192.168.0.153/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "infrastructure"
  tags            = ["docker", "containers", "runtime"]
  
  # Firewall
  enable_firewall = false
}

# Odoo ERP System (Container 125)
module "odoo" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 125
  hostname    = "odoo"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "6G"
  swap      = 1024
  
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
      ip       = "192.168.0.159/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "business"
  tags            = ["erp", "business", "odoo"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Odoo WebUI"
      dest    = ""
      dport   = "8069"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Paperless-ngx Document Management (Container 128)
module "paperless_ngx" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 128
  hostname    = "paperless-ngx"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "15G"
  swap      = 1024
  
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
  
  # Storage Mounts
  mount_points = [
    {
      key     = "mp0"
      slot    = 0
      storage = var.shared_data_storage
      mp      = "/data"
      size    = "10T"
    }
  ]
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.149/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "business"
  tags            = ["documents", "scanning", "ocr"]
  
  # Firewall
  enable_firewall = false
}

# ntfy Notification Server (Container 124)
module "ntfy" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 124
  hostname    = "ntfy"
  
  # Resources
  memory    = 256
  cores     = 1
  disk_size = "2G"
  swap      = 128
  
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
      ip       = "192.168.0.124/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "communication"
  tags            = ["notifications", "push", "iphone", "ubuntu"]
  
  # Firewall
  enable_firewall = false
}