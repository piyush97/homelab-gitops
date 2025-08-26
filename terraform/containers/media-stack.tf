# Media Stack Container Definitions
# Plex, Sonarr, Radarr, qBittorrent, Prowlarr, Lidarr, Overseerr, etc.

locals {
  # Common mount points for media containers
  common_media_mounts = [
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
  
  # Common network configuration
  primary_network = {
    name     = "eth0"
    bridge   = var.network_bridge
    gw       = var.primary_gateway
    firewall = false
  }
  
  # VPN network configuration for torrent containers
  vpn_network = {
    name     = "eth1"
    bridge   = "vmbr1"
    gw       = var.vpn_gateway
    firewall = true
  }
}

# Plex Media Server (Container 120)
module "plex" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 120
  hostname    = "plex"
  
  # Resources
  memory    = 4096
  cores     = 2
  disk_size = "8G"
  swap      = 2048
  
  # Template - Ubuntu 25.04 for bleeding edge
  template = "ubuntu-25.04-standard_25.04-1_amd64.tar.zst"
  ostype   = "ubuntu"
  
  # Security - Privileged for hardware acceleration
  privileged = true
  onboot     = true
  
  # Features
  features = {
    nesting = true
    mount   = ""
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.207/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["media-server", "gpu-passthrough", "privileged"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Plex Media Server"
      dest    = ""
      dport   = "32400"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# qBittorrent Torrent Client (Container 107)  
module "qbittorrent" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 107
  hostname    = "qbittorrent"
  
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
  
  # Features - TUN device for VPN
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Dual Network - Primary + VPN
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.132/24"
    }),
    merge(local.vpn_network, {
      ip = "10.10.10.2/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["torrent-client", "dual-network", "vpn"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "qBittorrent WebUI"
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

# Prowlarr Indexer Manager (Container 108)
module "prowlarr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 108
  hostname    = "prowlarr"
  
  # Resources
  memory    = 1024
  cores     = 2
  disk_size = "4G"
  swap      = 512
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device for VPN
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Dual Network - Primary + VPN
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.119/24"
    }),
    merge(local.vpn_network, {
      ip = "10.10.10.3/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["indexer", "dual-network", "vpn"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Prowlarr WebUI"
      dest    = ""
      dport   = "9696"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Sonarr TV Series Management (Container 112)
module "sonarr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 112
  hostname    = "sonarr"
  
  # Resources
  memory    = 512
  cores     = 2
  disk_size = "4G"
  swap      = 256
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.203/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["tv-automation", "arr-stack"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Sonarr WebUI"
      dest    = ""
      dport   = "8989"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Radarr Movie Management (Container 113)
module "radarr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 113
  hostname    = "radarr"
  
  # Resources
  memory    = 512
  cores     = 2
  disk_size = "4G"
  swap      = 256
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.165/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["movie-automation", "arr-stack"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Radarr WebUI"
      dest    = ""
      dport   = "7878"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Lidarr Music Management (Container 121)
module "lidarr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 121
  hostname    = "lidarr"
  
  # Resources
  memory    = 512
  cores     = 2
  disk_size = "4G"
  swap      = 256
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.177/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["music-automation", "arr-stack"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Lidarr WebUI"
      dest    = ""
      dport   = "8686"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Overseerr Media Requests (Container 114)
module "overseerr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 114
  hostname    = "overseerr"
  
  # Resources
  memory    = 1024
  cores     = 2
  disk_size = "8G"
  swap      = 512
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.120/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["media-requests", "frontend"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Overseerr WebUI"
      dest    = ""
      dport   = "5055"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# FlareSolverr Captcha Solver (Container 115)
module "flaresolverr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 115
  hostname    = "flaresolverr"
  
  # Resources
  memory    = 512
  cores     = 2
  disk_size = "6G"
  swap      = 256
  
  # Template - Debian 13 (Trixie)
  template = "debian-13-standard_13.0-1_amd64.tar.zst"
  
  # Security
  privileged = false
  onboot     = true
  
  # Features - TUN device
  features = {
    nesting = true
    mount   = "cifs,nfs"
  }
  
  # Storage Mounts
  mount_points = local.common_media_mounts
  
  # Network
  networks = [
    merge(local.primary_network, {
      ip = "192.168.0.138/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["captcha-solver", "support-service"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "FlareSolverr API"
      dest    = ""
      dport   = "8191"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# AutoBrr RSS Automation (Container 118)
module "autobrr" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 118
  hostname    = "autobrr"
  
  # Resources
  memory    = 1024
  cores     = 2
  disk_size = "8G"
  swap      = 512
  
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
    merge(local.primary_network, {
      ip = "192.168.0.107/24"
    })
  ]
  
  # Organization
  service_category = "media"
  tags            = ["rss-automation", "torrent-automation"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "AutoBrr WebUI"
      dest    = ""
      dport   = "7474"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}