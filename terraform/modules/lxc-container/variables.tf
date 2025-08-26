# LXC Container Module Variables

# Basic Configuration
variable "target_node" {
  description = "Proxmox node name"
  type        = string
}

variable "hostname" {
  description = "Container hostname"
  type        = string
}

variable "vmid" {
  description = "Container VM ID"
  type        = number
}

# OS Configuration
variable "template" {
  description = "LXC template name"
  type        = string
}

variable "ostype" {
  description = "OS type"
  type        = string
  default     = "debian"
}

variable "arch" {
  description = "Container architecture"
  type        = string
  default     = "amd64"
}

# Resource Configuration
variable "memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 512
}

variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 1
}

variable "swap" {
  description = "Swap size in MB"
  type        = number
  default     = 512
}

# Storage Configuration
variable "storage_pool" {
  description = "Storage pool for root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Root disk size"
  type        = string
  default     = "4G"
}

variable "mount_points" {
  description = "Additional mount points"
  type = list(object({
    key     = string
    slot    = number
    storage = string
    mp      = string
    size    = string
  }))
  default = []
}

# Network Configuration
variable "networks" {
  description = "Network interfaces"
  type = list(object({
    name     = string
    bridge   = string
    ip       = string
    gw       = string
    firewall = bool
    hwaddr   = optional(string)
  }))
  default = []
}

# Container Features
variable "features" {
  description = "Container features"
  type = object({
    nesting = bool
    mount   = string
  })
  default = {
    nesting = true
    mount   = ""
  }
}

# Security Configuration
variable "privileged" {
  description = "Run as privileged container"
  type        = bool
  default     = false
}

variable "onboot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

variable "start_on_create" {
  description = "Start container after creation"
  type        = bool
  default     = true
}

# SSH Configuration
variable "ssh_public_keys" {
  description = "SSH public keys"
  type        = string
  default     = ""
}

variable "password" {
  description = "Container root password"
  type        = string
  sensitive   = true
  default     = ""
}

# Startup Configuration
variable "startup_order" {
  description = "Container startup order"
  type        = number
  default     = null
}

# Tagging and Organization
variable "service_category" {
  description = "Service category tag"
  type        = string
  default     = "general"
}

variable "tags" {
  description = "Additional tags"
  type        = list(string)
  default     = []
}

# Firewall Configuration
variable "enable_firewall" {
  description = "Enable firewall for container"
  type        = bool
  default     = false
}

variable "firewall_policy_in" {
  description = "Firewall input policy"
  type        = string
  default     = "DROP"
}

variable "firewall_policy_out" {
  description = "Firewall output policy"
  type        = string
  default     = "ACCEPT"
}

variable "firewall_log_level" {
  description = "Firewall log level"
  type        = string
  default     = "info"
}

variable "firewall_rules" {
  description = "Firewall rules"
  type = list(object({
    type    = string
    action  = string
    comment = string
    dest    = string
    dport   = string
    enable  = bool
    iface   = string
    log     = string
    proto   = string
    source  = string
    sport   = string
  }))
  default = []
}