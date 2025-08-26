# LXC Container Module for Proxmox
# Reusable module for creating standardized LXC containers

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 3.0"
    }
  }
}

resource "proxmox_lxc" "container" {
  target_node  = var.target_node
  hostname     = var.hostname
  vmid         = var.vmid
  
  # OS Configuration
  ostemplate   = var.template
  ostype       = var.ostype
  arch         = var.arch
  
  # Resources
  memory       = var.memory
  cores        = var.cores
  swap         = var.swap
  
  # Storage
  rootfs {
    storage = var.storage_pool
    size    = var.disk_size
  }
  
  # Mount Points
  dynamic "mountpoint" {
    for_each = var.mount_points
    content {
      key     = mountpoint.value.key
      slot    = mountpoint.value.slot
      storage = mountpoint.value.storage  
      mp      = mountpoint.value.mp
      size    = mountpoint.value.size
    }
  }
  
  # Network Configuration  
  dynamic "network" {
    for_each = var.networks
    content {
      name     = network.value.name
      bridge   = network.value.bridge
      ip       = network.value.ip
      gw       = network.value.gw
      firewall = network.value.firewall
      hwaddr   = network.value.hwaddr
    }
  }
  
  # Container Features
  features {
    nesting = var.features.nesting
    mount   = var.features.mount
  }
  
  # Security & Boot Configuration
  unprivileged = !var.privileged
  onboot       = var.onboot
  start        = var.start_on_create
  
  # SSH Configuration
  ssh_public_keys = var.ssh_public_keys
  
  # Password (if not using SSH keys)
  password = var.password
  
  # Startup Configuration
  startup = var.startup_order != null ? "order=${var.startup_order}" : ""
  
  # Tags for organization
  tags = join(",", concat(var.tags, [var.service_category]))
  
  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore changes to these as they may be managed outside Terraform
      ssh_public_keys,
      password,
    ]
  }
}

# Firewall Rules (if enabled)
resource "proxmox_lxc_firewall" "container_firewall" {
  count = var.enable_firewall ? 1 : 0
  
  vmid = proxmox_lxc.container.vmid
  
  # Enable firewall
  enabled = true
  
  # Default policy
  policy_in  = var.firewall_policy_in
  policy_out = var.firewall_policy_out
  
  # Log level
  log_level_in  = var.firewall_log_level
  log_level_out = var.firewall_log_level
}

# Individual firewall rules
resource "proxmox_lxc_firewall_rule" "container_rules" {
  count = var.enable_firewall ? length(var.firewall_rules) : 0
  
  vmid = proxmox_lxc.container.vmid
  
  type     = var.firewall_rules[count.index].type
  action   = var.firewall_rules[count.index].action
  comment  = var.firewall_rules[count.index].comment
  dest     = var.firewall_rules[count.index].dest
  dport    = var.firewall_rules[count.index].dport
  enable   = var.firewall_rules[count.index].enable
  iface    = var.firewall_rules[count.index].iface
  log      = var.firewall_rules[count.index].log
  proto    = var.firewall_rules[count.index].proto
  source   = var.firewall_rules[count.index].source
  sport    = var.firewall_rules[count.index].sport
}