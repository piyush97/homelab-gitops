# Monitoring Stack Container Definitions
# Grafana, Prometheus, Uptime Kuma, PVE Exporter, Glance

locals {
  # Monitoring-specific mount points
  monitoring_mounts = [
    {
      key     = "mp0"
      slot    = 0
      storage = var.docker_storage
      mp      = "/docker"
      size    = "64G"
    }
  ]
}

# Grafana Dashboard Server (Container 110)
module "grafana" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 110
  hostname    = "grafana"
  
  # Resources
  memory    = 1024
  cores     = 1
  disk_size = "12G"
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
  
  # Storage Mounts
  mount_points = local.monitoring_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.243/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["dashboards", "visualization", "metrics"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Grafana WebUI"
      dest    = ""
      dport   = "3000"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Alpine Prometheus (Container 109)
module "alpine_prometheus" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 109
  hostname    = "alpine-prometheus"
  
  # Resources
  memory    = 256
  cores     = 1
  disk_size = "1G"
  swap      = 128
  
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
      ip       = "dhcp"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["metrics", "lightweight", "alpine"]
  
  # Firewall
  enable_firewall = false
}

# Proxmox VE Exporter (Container 106)
module "prometheus_pve_exporter" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 106
  hostname    = "prometheus-pve-exporter"
  
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
      ip       = "dhcp"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["metrics", "proxmox", "exporter"]
  
  # Firewall
  enable_firewall = false
}

# Uptime Kuma Service Monitoring (Container 123)
module "uptimekuma" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 123
  hostname    = "uptimekuma"
  
  # Resources
  memory    = 512
  cores     = 1
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
    mount   = ""
  }
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.181/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["uptime", "health-checks", "alerting"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Uptime Kuma WebUI"
      dest    = ""
      dport   = "3001"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = ""
      sport   = ""
    }
  ]
}

# Glance Dashboard (Container 119) 
module "glance" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 119
  hostname    = "glance"
  
  # Resources
  memory    = 512
  cores     = 1
  disk_size = "2G"
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
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.44/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["dashboard", "homelab", "frontend"]
  
  # Firewall
  enable_firewall = false
}