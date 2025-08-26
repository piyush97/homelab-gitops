# Proxmox Connection Variables
variable "proxmox_api_url" {
  description = "Proxmox VE API URL"
  type        = string
  default     = "https://piyushmehta:8006/api2/json"
}

variable "proxmox_api_user" {
  description = "Proxmox VE API user"
  type        = string
  default     = "root@pam"
}

variable "proxmox_api_password" {
  description = "Proxmox VE API password"
  type        = string
  sensitive   = true
}

variable "proxmox_api_tls_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

# Optional: API Token Variables (more secure than password)
variable "proxmox_api_token_id" {
  description = "Proxmox VE API Token ID"
  type        = string
  default     = ""
}

variable "proxmox_api_token_secret" {
  description = "Proxmox VE API Token Secret"
  type        = string
  sensitive   = true
  default     = ""
}

# Infrastructure Configuration
variable "target_node" {
  description = "Proxmox node name for deployments"
  type        = string
  default     = "piyushmehta"
}

variable "template_name" {
  description = "Default LXC template name"
  type        = string
  default     = "debian-12-standard_12.2-1_amd64.tar.zst"
}

variable "network_bridge" {
  description = "Primary network bridge"
  type        = string
  default     = "vmbr0"
}

variable "storage_pool" {
  description = "Storage pool for container root filesystems"
  type        = string
  default     = "local-lvm"
}

variable "shared_data_storage" {
  description = "Shared data storage mount point"
  type        = string
  default     = "data"
}

variable "docker_storage" {
  description = "Docker volumes storage"
  type        = string
  default     = "vault"
}

# Network Configuration
variable "primary_network_cidr" {
  description = "Primary network CIDR"
  type        = string
  default     = "192.168.0.0/24"
}

variable "primary_gateway" {
  description = "Primary network gateway"
  type        = string
  default     = "192.168.0.1"
}

variable "vpn_network_cidr" {
  description = "VPN network CIDR (vmbr1)"
  type        = string
  default     = "10.10.10.0/24"
}

variable "vpn_gateway" {
  description = "VPN network gateway"
  type        = string
  default     = "10.10.10.1"
}

# Container Configuration Defaults
variable "default_memory" {
  description = "Default memory allocation (MB)"
  type        = number
  default     = 512
}

variable "default_cores" {
  description = "Default CPU cores"
  type        = number
  default     = 1
}

variable "default_disk_size" {
  description = "Default root disk size (GB)"
  type        = string
  default     = "4G"
}

variable "default_swap" {
  description = "Default swap size (MB)"  
  type        = number
  default     = 512
}

# Service-specific configurations
variable "media_containers" {
  description = "Media stack container configurations"
  type = map(object({
    vmid        = number
    hostname    = string
    memory      = number
    cores       = number
    disk        = string
    swap        = number
    ip_address  = string
    template    = string
    privileged  = bool
    onboot      = bool
    features = object({
      nesting = bool
      mount   = string
    })
    mounts = list(object({
      key     = string
      slot    = number  
      storage = string
      mp      = string
      size    = string
    }))
    networks = list(object({
      name      = string
      bridge    = string
      ip        = string
      gw        = string
      firewall  = bool
    }))
  }))
  default = {}
}

variable "monitoring_containers" {
  description = "Monitoring stack container configurations"
  type = map(object({
    vmid        = number
    hostname    = string
    memory      = number
    cores       = number
    disk        = string
    swap        = number
    ip_address  = string
    template    = string
    privileged  = bool
    onboot      = bool
  }))
  default = {}
}

variable "security_containers" {
  description = "Security stack container configurations"
  type = map(object({
    vmid        = number
    hostname    = string
    memory      = number
    cores       = number
    disk        = string
    swap        = number
    ip_address  = string
    template    = string
    privileged  = bool
    onboot      = bool
  }))
  default = {}
}

# Notification Configuration
variable "notification_webhook_url" {
  description = "Webhook URL for deployment notifications"
  type        = string
  default     = "https://notifications.piyushmehta.com"
}

# Tags for resource organization
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment   = "homelab"
    ManagedBy     = "terraform"
    GitOpsEnabled = "true"
  }
}