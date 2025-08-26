# Advanced Monitoring Stack Container Definitions
# Grafana, Prometheus, Loki, AlertManager, Blackbox Exporter, Uptime Kuma, PVE Exporter, Glance

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

# Loki Log Aggregation (Container 130)
module "loki" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 130
  hostname    = "loki"
  
  # Resources
  memory    = 2048
  cores     = 2
  disk_size = "8G"
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
  mount_points = local.monitoring_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.200/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["logs", "aggregation", "loki"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Loki HTTP"
      dest    = ""
      dport   = "3100"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = "192.168.0.0/24"
      sport   = ""
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Loki gRPC"
      dest    = ""
      dport   = "9095"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = "192.168.0.0/24"
      sport   = ""
    }
  ]
}

# AlertManager Alerting (Container 131)
module "alertmanager" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 131
  hostname    = "alertmanager"
  
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
  
  # Storage Mounts
  mount_points = local.monitoring_mounts
  
  # Network
  networks = [
    {
      name     = "eth0"
      bridge   = var.network_bridge
      ip       = "192.168.0.201/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["alerting", "notifications", "alertmanager"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "AlertManager WebUI"
      dest    = ""
      dport   = "9093"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = "192.168.0.0/24"
      sport   = ""
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "AlertManager Cluster"
      dest    = ""
      dport   = "9094"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = "192.168.0.0/24"
      sport   = ""
    }
  ]
}

# Blackbox Exporter External Monitoring (Container 132)
module "blackbox_exporter" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 132
  hostname    = "blackbox-exporter"
  
  # Resources
  memory    = 256
  cores     = 1
  disk_size = "2G"
  swap      = 128
  
  # Template - Alpine 3.22.1 (Lightweight)
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
      ip       = "192.168.0.202/24"
      gw       = var.primary_gateway
      firewall = true
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["external-monitoring", "blackbox", "alpine"]
  
  # Firewall
  enable_firewall = true
  firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "Blackbox Exporter"
      dest    = ""
      dport   = "9115"
      enable  = true
      iface   = ""
      log     = "nolog"
      proto   = "tcp"
      source  = "192.168.0.0/24"
      sport   = ""
    }
  ]
}

# Promtail Log Shipping (Container 133)
module "promtail" {
  source = "../modules/lxc-container"
  
  # Basic Configuration
  target_node = var.target_node
  vmid        = 133
  hostname    = "promtail"
  
  # Resources
  memory    = 512
  cores     = 1
  disk_size = "4G"
  swap      = 256
  
  # Template - Alpine 3.22.1 (Lightweight)
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
      ip       = "192.168.0.204/24"
      gw       = var.primary_gateway
      firewall = false
    }
  ]
  
  # Organization
  service_category = "monitoring"
  tags            = ["log-shipping", "promtail", "alpine"]
  
  # Firewall
  enable_firewall = false
}