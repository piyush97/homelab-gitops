# 🏗️ Architecture Overview

🔗 **Repository**: [https://github.com/piyush97/homelab-gitops](https://github.com/piyush97/homelab-gitops)

Comprehensive architecture documentation for the 24-container Proxmox homelab infrastructure.

## 🎯 System Overview

### Infrastructure Foundation
- **Host Platform**: Proxmox VE 8.14 on Linux 6.14.8-2-pve
- **Hardware**: 31GB RAM, Multi-core CPU optimized for virtualization
- **Container Technology**: LXC containers for efficient resource utilization
- **Management**: GitOps-driven Infrastructure as Code approach

### Network Architecture
```
Internet
    │
    ├── Router (192.168.0.1)
    │
    ├── Primary Network (vmbr0: 192.168.0.0/24)
    │   ├── SWAG (192.168.0.3) ──┐
    │   ├── File Server (192.168.0.5) │
    │   ├── Immich (192.168.0.15)     │── Public Services
    │   ├── Grafana (192.168.0.243)   │
    │   └── [18 other containers]   ──┘
    │
    └── VPN Network (vmbr1: 10.10.10.0/24)
        ├── Wireguard Gateway (10.10.10.1)
        ├── qBittorrent (10.10.10.2)
        └── Prowlarr (10.10.10.3)
```

## 📦 Container Categories

**Total Containers**: 28 (24 original + 4 advanced monitoring)

### 🎬 Media Stack (9 containers)
**Purpose**: Media acquisition, organization, and streaming

| Service | Container | IP | Purpose |
|---------|-----------|----|---------| 
| Plex | `plex` (120) | 192.168.0.207 | Media streaming server |
| qBittorrent | `qbittorrent` (107) | 192.168.0.132 + VPN | Torrent client |
| Sonarr | `sonarr` (112) | 192.168.0.203 | TV show automation |
| Radarr | `radarr` (113) | 192.168.0.165 | Movie automation |
| Lidarr | `lidarr` (121) | 192.168.0.177 | Music automation |
| Prowlarr | `prowlarr` (108) | 192.168.0.119 + VPN | Indexer management |
| Overseerr | `overseerr` (114) | 192.168.0.120 | Media request management |
| FlareSolverr | `flaresolverr` (115) | 192.168.0.138 | Captcha solving service |
| AutoBrr | `autobrr` (118) | 192.168.0.107 | Automated RSS downloads |

**Key Features**:
- GPU hardware acceleration (Plex)
- VPN-routed torrent traffic
- Integrated *arr stack workflow
- Automated media organization

### 📊 Advanced Monitoring Stack (9 containers)
**Purpose**: Comprehensive observability with metrics, logs, and alerting

| Service | Container | IP | Purpose |
|---------|-----------|----|---------| 
| Grafana | `grafana` (110) | 192.168.0.243 | Visualization dashboards |
| Prometheus | `alpine_prometheus` (109) | DHCP | Metrics collection |
| **Loki** | `loki` (130) | 192.168.0.200 | **Log aggregation** |
| **AlertManager** | `alertmanager` (131) | 192.168.0.201 | **Advanced alerting** |
| **Blackbox Exporter** | `blackbox_exporter` (132) | 192.168.0.202 | **External monitoring** |
| **Promtail** | `promtail` (133) | 192.168.0.204 | **Log shipping** |
| PVE Exporter | `prometheus_pve_exporter` (106) | DHCP | Proxmox metrics |
| Uptime Kuma | `uptimekuma` (123) | 192.168.0.181 | Service monitoring |
| Glance | `glance` (119) | 192.168.0.44 | System dashboard |

**Advanced Observability Features**:
- **Infrastructure Metrics**: CPU, memory, storage, network performance
- **Centralized Logging**: Log aggregation from all 28 containers
- **External Monitoring**: HTTP/TCP endpoint health checks
- **Advanced Alerting**: Intelligent routing with mobile notifications
- **Custom Dashboards**: Service-specific visualizations and log correlation
- **Real-time Streaming**: Live log tailing and metric updates

### 🔒 Security Stack (4 containers)
**Purpose**: Network security, access control, and encryption

| Service | Container | IP | Purpose |
|---------|-----------|----|---------| 
| SWAG | `swag` (100) | 192.168.0.3 | Reverse proxy + SSL |
| Wireguard | `wireguard` (116) | 192.168.0.219 + VPN | VPN server |
| Vaultwarden | `vaultwarden` (104) | 192.168.0.248 | Password manager |
| RustDesk | `rustdeskserver` (103) | 192.168.0.140 | Remote desktop server |

**Security Features**:
- Let's Encrypt SSL automation
- Network-level VPN isolation
- Self-hosted password management
- Secure remote access capabilities

### 🏢 Business & Storage (7 containers)
**Purpose**: Productivity applications and data management

| Service | Container | IP | Purpose |
|---------|-----------|----|---------| 
| Immich | `immich` (105) | 192.168.0.15 | Photo management + AI |
| Immich Backup | `immich_backup` (117) | 192.168.0.10 | Photo backup instance |
| File Server | `fileserver` (102) | 192.168.0.5 | NAS + Cockpit |
| Paperless-ngx | `paperless_ngx` (128) | 192.168.0.149 | Document management |
| Odoo | `odoo` (125) | 192.168.0.159 | ERP system |
| Google Drive | `drive` (101) | 192.168.0.126 | Cloud sync |
| Docker Host | `docker` (111) | 192.168.0.153 | Container runtime |
| ntfy | `ntfy` (124) | 192.168.0.124 | Notification server |

**Business Capabilities**:
- AI-powered photo organization
- Document digitization and OCR
- Enterprise resource planning
- Centralized file storage and sharing

## 🗄️ Storage Architecture

### Storage Pools
```
Proxmox Host Storage:
├── local-lvm (Container root filesystems)
├── data (Directory: /vault/data - Shared container data)
├── vault (ZFS: Subvolumes for Docker data)
└── backups (Dedicated backup storage)
```

### Mount Point Strategy
**Shared Data Mount** (`/data`):
- 10TB shared across containers
- Media files, documents, photos
- Cross-container data sharing

**Docker Volumes** (`/docker`):
- 128GB per container (standard)
- 64GB for monitoring containers
- Container-specific application data

**Examples**:
```bash
# Media containers
/data/media/movies    # Shared movie library
/data/media/tv        # Shared TV library  
/data/downloads       # Shared download directory

# Business containers  
/data/immich/photos   # Photo library
/data/paperless/docs  # Document archive
/data/backups         # Backup storage
```

## 🌐 Network Design

### Primary Network (vmbr0: 192.168.0.0/24)
- **Purpose**: Main homelab network
- **Gateway**: 192.168.0.1
- **Services**: All containers have primary connectivity
- **Firewall**: Selective port-based protection

### VPN Network (vmbr1: 10.10.10.0/24) 
- **Purpose**: Isolated network for torrent traffic
- **Gateway**: 10.10.10.1 (Wireguard container)
- **Clients**: qBittorrent, Prowlarr
- **Security**: All traffic routed through VPN

### Dual-Network Containers
**Containers with both networks**:
- `qbittorrent` (107): Management via primary, traffic via VPN
- `prowlarr` (108): API access via primary, indexer access via VPN
- `wireguard` (116): VPN server bridging both networks

## 🔥 Firewall Architecture

### Container-Level Firewalls (10/24 containers)
**HTTP/HTTPS Services**:
- SWAG: 80, 443 (public ingress)
- Grafana: 3000 (monitoring dashboard)
- Immich: 2283 (photo management)
- Plex: 32400 (media streaming)

**Management Interfaces**:
- File Server: 9090 (Cockpit), 445 (SMB)
- Uptime Kuma: 3001 (monitoring)
- Vaultwarden: 8080 (password manager)

**Application-Specific**:
- Wireguard: 51820/UDP (VPN)
- *arr Stack: Various ports (8989, 7878, etc.)

### Network-Level Security
- **Proxmox Firewall**: Host-level protection
- **Container Isolation**: LXC namespace separation
- **VPN Routing**: Dedicated network for sensitive traffic

## 🔧 Resource Allocation

### Memory Distribution (27.5GB total)
**High Memory** (4GB+):
- Immich: 4GB (AI processing)
- Immich Backup: 9GB (stopped by default)
- Plex: 4GB (transcoding)

**Medium Memory** (2GB):
- qBittorrent, Wireguard, File Server
- Docker Host, Vaultwarden, Odoo, Paperless-ngx

**Low Memory** (≤1GB):
- *arr stack services
- Monitoring services
- Utility containers

### CPU Allocation
- **High**: Media servers (Plex: 2 cores, Immich: 4 cores)
- **Medium**: Automation services (2 cores each)
- **Low**: Monitoring and utilities (1 core each)

### Storage Optimization
- **Root Disks**: Minimal sizes (2-15GB) for OS + applications
- **Data Mounts**: Large shared volumes for actual content
- **Docker Volumes**: Separate volumes for application state

## 🔄 GitOps Workflow

### Infrastructure as Code
```
Developer/Admin
    │
    ├── Git Commit (Infrastructure changes)
    │
    ├── GitHub Actions (Validation, Planning)
    │
    ├── Terraform Apply (Infrastructure provisioning)
    │
    ├── Ansible Deploy (Service configuration)
    │
    └── Monitoring & Notifications (Success/failure)
```

### Change Management Process
1. **Code Changes**: Infrastructure modifications in Git
2. **Validation**: Automated testing and validation
3. **Planning**: Terraform plan review
4. **Deployment**: Automated or manual apply
5. **Configuration**: Ansible service setup
6. **Monitoring**: Health checks and notifications

## 📊 Scalability Considerations

### Horizontal Scaling
- **Container Distribution**: Spread across multiple Proxmox nodes
- **Load Balancing**: SWAG reverse proxy for HTTP services
- **Service Mesh**: Future consideration for inter-service communication

### Vertical Scaling  
- **Resource Adjustment**: Easy container resource modification
- **Storage Expansion**: ZFS pool growth capabilities
- **Network Bandwidth**: Dedicated networks for high-traffic services

### Disaster Recovery
- **Infrastructure Recovery**: Complete rebuild from Git repository
- **Data Backup**: Automated daily backups with retention
- **Service Recovery**: Automated health checks and restart procedures

## 🎯 Design Principles

### Reliability
- **Service Separation**: Isolated containers for fault tolerance
- **Health Monitoring**: Comprehensive monitoring stack
- **Automated Recovery**: Self-healing capabilities where possible

### Security
- **Least Privilege**: Minimal container privileges (22/24 unprivileged)
- **Network Segmentation**: VPN isolation for sensitive traffic
- **Access Control**: Firewall rules and authentication

### Maintainability  
- **Infrastructure as Code**: Version-controlled infrastructure
- **Standardization**: Consistent container configurations
- **Documentation**: Self-documenting through code

### Performance
- **Resource Optimization**: Right-sized container allocations
- **Hardware Acceleration**: GPU passthrough for media processing
- **Network Efficiency**: Dual-network design for traffic optimization

This architecture provides a robust, scalable, and maintainable foundation for a modern homelab environment while embracing enterprise-grade DevOps practices.