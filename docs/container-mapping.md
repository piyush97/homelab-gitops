# Container Mapping: Existing → GitOps

🔗 **Repository**: [https://github.com/piyush97/homelab-gitops](https://github.com/piyush97/homelab-gitops)

This document maps the complete 28-container homelab infrastructure to GitOps Terraform definitions, including the new advanced monitoring stack.

## Overview

All existing containers have been successfully defined in Infrastructure as Code using Terraform. The GitOps implementation preserves all existing functionality while adding version control, automation capabilities, and standardized deployment processes.

## Container Mapping by Service Category

### 🎬 Media Stack (8 containers)
**File**: `terraform/containers/media-stack.tf`

| VMID | Hostname | Current IP | Terraform Module | Key Features |
|------|----------|------------|------------------|--------------|
| 120 | plex | 192.168.0.207 | `plex` | GPU passthrough, privileged, 4GB RAM |
| 107 | qbittorrent | 192.168.0.132 + 10.10.10.2 | `qbittorrent` | Dual network (VPN), 2GB RAM |
| 108 | prowlarr | 192.168.0.119 + 10.10.10.3 | `prowlarr` | Dual network (VPN), indexer |
| 112 | sonarr | 192.168.0.203 | `sonarr` | TV automation, *arr stack |
| 113 | radarr | 192.168.0.165 | `radarr` | Movie automation, *arr stack |
| 121 | lidarr | 192.168.0.177 | `lidarr` | Music automation, *arr stack |
| 114 | overseerr | 192.168.0.120 | `overseerr` | Media requests frontend |
| 115 | flaresolverr | 192.168.0.138 | `flaresolverr` | Captcha solver support |
| 118 | autobrr | 192.168.0.107 | `autobrr` | RSS torrent automation |

### 📊 Advanced Monitoring & Observability (9 containers)
**File**: `terraform/containers/monitoring.tf`

| VMID | Hostname | Current IP | Terraform Module | Key Features |
|------|----------|------------|------------------|--------------|
| 110 | grafana | 192.168.0.243 | `grafana` | Enhanced dashboards with log correlation |
| 109 | alpine-prometheus | DHCP | `alpine_prometheus` | Lightweight metrics, Alpine |
| **130** | **loki** | **192.168.0.200** | `loki` | **Centralized logging, 31-day retention** |
| **131** | **alertmanager** | **192.168.0.201** | `alertmanager` | **Intelligent alerting with mobile notifications** |
| **132** | **blackbox-exporter** | **192.168.0.202** | `blackbox_exporter` | **External HTTP/TCP monitoring** |
| **133** | **promtail** | **192.168.0.204** | `promtail` | **Log shipping to Loki** |
| 106 | prometheus-pve-exporter | DHCP | `prometheus_pve_exporter` | Proxmox metrics |
| 123 | uptimekuma | 192.168.0.181 | `uptimekuma` | Service monitoring |
| 119 | glance | 192.168.0.44 | `glance` | Dashboard frontend |

### 🔒 Security & Network (4 containers)
**File**: `terraform/containers/security.tf`

| VMID | Hostname | Current IP | Terraform Module | Key Features |
|------|----------|------------|------------------|--------------|
| 100 | SWAG | 192.168.0.3 | `swag` | Reverse proxy, SSL, firewall |
| 116 | wireguard | 192.168.0.219 + 10.10.10.1 | `wireguard` | VPN server, dual network |
| 104 | alpine-vaultwarden | 192.168.0.248 | `vaultwarden` | Password manager, Alpine |
| 103 | rustdeskserver | 192.168.0.140 | `rustdeskserver` | Remote desktop server |

### 🏢 Business & Storage (7 containers)
**File**: `terraform/containers/business.tf`

| VMID | Hostname | Current IP | Terraform Module | Key Features |
|------|----------|------------|------------------|--------------|
| 105 | immich | 192.168.0.15 | `immich` | Photo management, GPU, privileged |
| 117 | immich-backup | 192.168.0.10 | `immich_backup` | Backup instance, stopped by default |
| 102 | fileserver | 192.168.0.5 | `fileserver` | NAS, Cockpit, SMB shares |
| 101 | drive | 192.168.0.126 | `drive` | Google Drive sync, Alpine |
| 111 | docker | 192.168.0.153 | `docker` | Container runtime host |
| 125 | odoo | 192.168.0.159 | `odoo` | ERP system, firewall |
| 128 | paperless-ngx | 192.168.0.149 | `paperless_ngx` | Document management |
| 124 | ntfy | 192.168.0.124 | `ntfy` | Notification server, Ubuntu 25.04 |

## Network Configuration Mapping

### Primary Network (vmbr0) - 192.168.0.x/24
- **Gateway**: 192.168.0.1
- **Bridge**: `var.network_bridge`
- **All containers**: Connected to primary network
- **Static IPs**: Preserved in Terraform configuration
- **DHCP IPs**: Maintained for containers using dynamic allocation

### Secondary Network (vmbr1) - 10.10.10.x/24
- **Gateway**: 10.10.10.1 (wireguard container)
- **Bridge**: `vmbr1`
- **VPN-routed containers**: qbittorrent (10.10.10.2), prowlarr (10.10.10.3)
- **Purpose**: Isolated torrent traffic through VPN

## Storage Configuration Mapping

### Mount Points
All storage configurations are preserved through Terraform variables:

- **Shared Data**: `var.shared_data_storage` → `/data` (10T)
- **Docker Volumes**: `var.docker_storage` → `/docker` (128G)
- **Monitoring**: Specific 64G Docker volume for monitoring stack

### Mount Point Patterns
```hcl
# Business containers
mount_points = local.business_mounts

# Media containers  
mount_points = local.common_media_mounts

# Security containers
mount_points = local.security_mounts

# Monitoring containers
mount_points = local.monitoring_mounts
```

## Firewall Rules Mapping

All existing firewall configurations are preserved:

### Containers with Firewall Rules
- **SWAG (100)**: HTTP/HTTPS (80, 443)
- **Fileserver (102)**: Cockpit (9090), SMB (445, 139, 138, 137)
- **Vaultwarden (104)**: WebUI (8080)
- **Immich (105)**: WebUI (2283)
- **qBittorrent (107)**: WebUI (8080)
- **Prowlarr (108)**: WebUI (9696)
- **Grafana (110)**: WebUI (3000)
- **Sonarr (112)**: WebUI (8989)
- **Radarr (113)**: WebUI (7878)
- **Overseerr (114)**: WebUI (5055)
- **FlareSolverr (115)**: API (8191)
- **Wireguard (116)**: VPN (51820/UDP) + VPN network traffic
- **AutoBrr (118)**: WebUI (7474)
- **Plex (120)**: Media Server (32400)
- **Lidarr (121)**: WebUI (8686)
- **Uptime Kuma (123)**: WebUI (3001)
- **Odoo (125)**: WebUI (8069)

## Resource Allocation Mapping

All existing resource allocations are preserved:

### High Resource Containers
- **Immich (105)**: 4GB RAM, 4 cores (GPU passthrough)
- **Immich Backup (117)**: 9GB RAM, 4 cores (stopped)
- **Plex (120)**: 4GB RAM, 2 cores (GPU passthrough)

### Medium Resource Containers
- **qBittorrent (107)**: 2GB RAM, 2 cores
- **Wireguard (116)**: 2GB RAM, 2 cores
- **Fileserver (102)**: 2GB RAM, 2 cores
- **Docker (111)**: 2GB RAM, 2 cores
- **Vaultwarden (104)**: 2GB RAM, 2 cores
- **Odoo (125)**: 2GB RAM, 2 cores
- **Paperless-ngx (128)**: 2GB RAM, 2 cores

### Lightweight Containers
- **Most *arr containers**: 512MB-1GB RAM, 1-2 cores
- **Alpine containers**: 256-512MB RAM, 1 core
- **Utility containers**: 256-512MB RAM, 1 core

## Template Mapping

Templates are preserved based on existing OS choices:

- **Debian 13 "Trixie"**: `debian-13-standard_13.0-1_amd64.tar.zst`
- **Ubuntu 25.04**: `ubuntu-25.04-standard_25.04-1_amd64.tar.zst`
- **Alpine 3.22.1**: `alpine-3.22-default_20240606_amd64.tar.xz`

## Special Features Mapping

### Privileged Containers
- **Immich (105)**: `privileged = true` (GPU access)
- **Immich Backup (117)**: `privileged = true` (GPU access)
- **Plex (120)**: `privileged = true` (GPU access)

### Feature Configurations
```hcl
features = {
  nesting = true           # Docker/container support
  mount   = "cifs,nfs"    # Network filesystem support
}
```

### Auto-start Behavior
- **Most containers**: `onboot = true`
- **Immich Backup (117)**: `onboot = false, start_on_create = false`

## Migration Benefits

### Disaster Recovery
- Complete infrastructure can be rebuilt from Git repository
- No manual container configuration required
- Consistent deployment across environments

### Change Management
- All infrastructure changes tracked in version control
- Rollback capability for configuration changes
- Audit trail for all modifications

### Automation Ready
- Foundation for CI/CD pipeline deployment
- Infrastructure drift detection capabilities
- Automated testing and validation

### Documentation as Code
- Infrastructure self-documents through Terraform
- No separate documentation maintenance required
- Always up-to-date configuration reference

This mapping ensures 100% compatibility between existing infrastructure and GitOps implementation while adding modern DevOps capabilities.