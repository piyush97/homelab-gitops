# LXC Container Module Outputs

output "vmid" {
  description = "Container VM ID"
  value       = proxmox_lxc.container.vmid
}

output "hostname" {
  description = "Container hostname"
  value       = proxmox_lxc.container.hostname
}

output "target_node" {
  description = "Target Proxmox node"
  value       = proxmox_lxc.container.target_node
}

output "ostemplate" {
  description = "OS template used"
  value       = proxmox_lxc.container.ostemplate
}

output "memory" {
  description = "Allocated memory in MB"
  value       = proxmox_lxc.container.memory
}

output "cores" {
  description = "Allocated CPU cores"
  value       = proxmox_lxc.container.cores
}

output "swap" {
  description = "Swap size in MB"
  value       = proxmox_lxc.container.swap
}

output "disk_size" {
  description = "Root disk size"
  value       = var.disk_size
}

output "ip_addresses" {
  description = "Container IP addresses"
  value = [
    for network in var.networks : {
      interface = network.name
      ip        = network.ip
      bridge    = network.bridge
      gateway   = network.gw
    }
  ]
}

output "mount_points" {
  description = "Container mount points"
  value = var.mount_points
}

output "unprivileged" {
  description = "Whether container is unprivileged"
  value       = proxmox_lxc.container.unprivileged
}

output "onboot" {
  description = "Whether container starts on boot"
  value       = proxmox_lxc.container.onboot
}

output "tags" {
  description = "Container tags"
  value       = proxmox_lxc.container.tags
}

output "firewall_enabled" {
  description = "Whether firewall is enabled"
  value       = var.enable_firewall
}

output "service_category" {
  description = "Service category"
  value       = var.service_category
}

# Resource summary for inventory generation
output "ansible_host_vars" {
  description = "Ansible host variables"
  value = {
    ansible_host = length(var.networks) > 0 ? split("/", var.networks[0].ip)[0] : null
    hostname     = var.hostname
    vmid         = var.vmid
    memory       = var.memory
    cores        = var.cores
    service_category = var.service_category
    privileged   = var.privileged
    mount_points = var.mount_points
    networks     = var.networks
  }
}

# Summary for monitoring and documentation
output "container_summary" {
  description = "Container summary for documentation"
  value = {
    vmid            = var.vmid
    hostname        = var.hostname
    service_category = var.service_category
    memory          = "${var.memory}MB"
    cores           = var.cores
    disk            = var.disk_size
    primary_ip      = length(var.networks) > 0 ? var.networks[0].ip : "DHCP"
    privileged      = var.privileged ? "Yes" : "No"
    onboot          = var.onboot ? "Yes" : "No"
    firewall        = var.enable_firewall ? "Enabled" : "Disabled"
    template        = var.template
  }
}