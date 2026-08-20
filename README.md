# 🏠 Homelab GitOps Infrastructure

[![CI](https://github.com/piyush97/homelab-gitops/actions/workflows/ci.yml/badge.svg)](https://github.com/piyush97/homelab-gitops/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/ansible-%23EE0000.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](https://www.proxmox.com/)
[![GitOps](https://img.shields.io/badge/GitOps-326CE5.svg?style=for-the-badge&logo=git&logoColor=white)](https://about.gitlab.com/topics/gitops/)

## Overview

Infrastructure as Code (IaC) and GitOps implementation for a 28-container Proxmox homelab featuring media services, advanced monitoring & observability, security, and business applications.

🔗 **Official Documentation**: [https://github.com/piyush97/homelab-docs](https://piyush97.github.io/homelab-docs)

## 🏗️ Infrastructure

### Container Services (28 total)
- **🎬 Media Stack**: Plex, Sonarr, Radarr, qBittorrent, Prowlarr, Lidarr, Overseerr, FlareSolverr, AutoBrr
- **📊 Advanced Monitoring**: Grafana, Prometheus, **Loki**, **AlertManager**, **Blackbox Exporter**, **Promtail**, Uptime Kuma, PVE Exporter, Glance
- **🔒 Security**: SWAG, Wireguard, Vaultwarden, RustDesk
- **🏢 Business**: Odoo ERP, Paperless-ngx, Immich, File Server, Google Drive
- **🔔 Communication**: ntfy notifications

### Architecture Diagram

> Full details in [`docs/architecture.md`](docs/architecture.md)

```
                        ┌─────────────────────────────────────┐
                        │          Internet / WAN             │
                        └──────────────────┬──────────────────┘
                                           │
                        ┌──────────────────▼──────────────────┐
                        │            Router (192.168.0.1)      │
                        └──────────┬──────────────┬───────────┘
                                   │              │
              ┌────────────────────▼─────┐   ┌────▼──────────────────────┐
              │  vmbr0 · 192.168.0.0/24  │   │  vmbr1 · 10.10.10.0/24    │
              │  (Primary network)       │   │  (VPN network)            │
              └──────┬──────────┬────────┘   └──────┬────────────────────┘
                     │          │                   │
   ┌─────────────────▼─┐  ┌─────▼─────────────┐  ┌──▼──────────────────┐
   │ 🔒 Security (4)   │  │ 🎬 Media (9)      │  │ VPN-routed traffic  │
   │ ──────────────────│  │ ──────────────────│  │ ────────────────────│
   │ SWAG (100)        │  │ Plex (120)        │  │ qBittorrent (107)   │
   │ Wireguard (116)   │  │ Sonarr (112)      │  │ Prowlarr (108)      │
   │ Vaultwarden (104) │  │ Radarr (113)      │  │ Wireguard GW (116)  │
   │ RustDesk (103)    │  │ Lidarr (121)      │  └─────────────────────┘
   │                   │  │ Overseerr (114)   │
   └─────────┬─────────┘  │ FlareSolverr (115)│
             │            │ AutoBrr (118)     │
             │            │ qBittorrent (107) │
             │            │ Prowlarr (108)    │
             │            └─────────┬─────────┘
             │                      │
             │   ┌──────────────────▼──────────────────┐
             │   │ 📊 Monitoring & Observability (9)   │
             │   │ ─────────────────────────────────── │
             │   │ Grafana (110) · Prometheus (109)    │
             │   │ Loki (130) · AlertManager (131)     │
             │   │ Blackbox (132) · Promtail (133)     │
             │   │ Uptime Kuma (123) · Glance (119)    │
             │   │ PVE Exporter (106)                  │
             │   └──────────────────┬──────────────────┘
             │                      │
   ┌─────────▼──────────────────────▼──────────────────────────┐
   │ 🏢 Business & Storage (8)                                 │
   │ ───────────────────────────────────────────────────────── │
   │ Immich (105) · Immich Backup (117) · File Server (102)    │
   │ Paperless-ngx (128) · Odoo (125) · Google Drive (101)     │
   │ Docker Host (111) · ntfy (124)                            │
   └──────────────────────────┬───────────────────────────────┘
                              │
   ┌──────────────────────────▼───────────────────────────────┐
   │ 🗄️ Storage: ZFS · local-lvm · data (/data 10T) ·         │
   │             vault (/docker 128G) · backups               │
   └──────────────────────────────────────────────────────────┘
```

**Flow**: Internet → SWAG reverse proxy → per-category LXC containers on `vmbr0`; torrent traffic (qBittorrent, Prowlarr) is isolated on `vmbr1` and routed through the Wireguard VPN. All 28 containers are provisioned by Terraform (`terraform/`) and configured by Ansible (`ansible/`), with metrics/logs aggregated by the monitoring stack.

### Technology Stack
- **Virtualization**: Proxmox VE 8.14 on Linux 6.14.8-2-pve
- **Operating Systems**: Debian 13 (Trixie), Ubuntu 25.04 (Plucky), Alpine 3.22.1
- **Networking**: Dual bridge setup (vmbr0: 192.168.0.x, vmbr1: 10.10.10.x for VPN)
- **Storage**: ZFS pool with subvolumes, 10TB shared data, 128GB Docker volumes

## 🚀 GitOps Workflow

### 1. Infrastructure Definition
- **Terraform**: LXC container provisioning, network configuration, resource allocation
- **Modules**: Reusable components for different service types
- **State Management**: Remote state with locking

### 2. Configuration Management  
- **Ansible**: Service deployment, application configuration, secret management
- **Roles**: Modular playbooks for different service categories
- **Inventory**: Dynamic inventory from Terraform outputs

### 3. Continuous Deployment
- **GitHub Actions**: Automated testing, planning, and deployment
- **Pull Request Workflow**: Review-based infrastructure changes
- **Rollback Procedures**: Safe deployment practices with automated recovery

## 📁 Repository Structure

```
homelab-gitops/
├── LICENSE                    # MIT License
├── Makefile                   # Common automation tasks
├── scripts/                   # Validation scripts
├── docs/                      # Architecture & deployment docs
│   ├── architecture.md        # Full architecture overview
│   ├── container-mapping.md   # Container → GitOps mapping
│   ├── deployment-guide.md    # Deployment guide
│   └── advanced-monitoring.md # Monitoring/observability stack
├── terraform/                 # Infrastructure as Code (HCL)
│   ├── providers.tf           # Proxmox provider configuration
│   ├── variables.tf           # Global variables
│   ├── containers/            # Container definitions by category
│   │   ├── media-stack.tf     # Media services (Plex, Sonarr, etc.)
│   │   ├── monitoring.tf      # Grafana, Prometheus, Loki, etc.
│   │   ├── security.tf        # SWAG, Wireguard, Vaultwarden
│   │   └── business.tf        # Odoo, Paperless-ngx, Immich
│   └── modules/               # Reusable Terraform modules
│       └── lxc-container/     # Standard LXC container module
├── ansible/                   # Configuration management
│   ├── ansible.cfg            # Ansible configuration
│   ├── inventory/             # Host inventories
│   ├── playbooks/             # Deployment playbooks
│   ├── roles/                 # Reusable roles
│   ├── group_vars/            # Group-specific variables
│   └── tasks/                 # Task includes
└── .github/workflows/         # CI/CD automation
    ├── ci.yml                 # PR/push validation (Terraform + Ansible)
    ├── terraform-validate.yml # Terraform validation
    ├── ansible-lint.yml       # Ansible linting
    ├── drift-detection.yml    # Scheduled drift detection
    └── deploy.yml             # Manual deploy workflow
```

## 🔧 Getting Started

### Prerequisites
- Proxmox VE cluster access
- Terraform >= 1.6.0
- Ansible >= 2.15.0
- Git configured with SSH keys

### Quick Start
```bash
# Clone the repository
git clone https://github.com/piyush97/homelab-gitops.git
cd homelab-gitops

# Initialize Terraform
cd terraform
terraform init
terraform plan

# Run Ansible playbooks
cd ../ansible
ansible-playbook -i inventory playbooks/site.yml
```

## 📊 Monitoring & Notifications

- **Real-time Dashboards**: Grafana with Prometheus metrics
- **Service Monitoring**: Uptime Kuma for endpoint health checks
- **iPhone Notifications**: ntfy integration for critical alerts
- **Infrastructure Monitoring**: Host resources, container status, storage alerts

## 🔐 Security Features

- **Network Segmentation**: Firewall rules for 10/24 containers
- **VPN Access**: Wireguard for secure remote access
- **Password Management**: Vaultwarden for credential storage
- **SSL Termination**: SWAG reverse proxy with Let's Encrypt

## 📱 Notification System

Real-time iPhone notifications via ntfy server:
- **Critical Alerts** 🔴: Container failures, storage issues
- **Warnings** 🟡: Resource thresholds, service degradation  
- **Info** ℹ️: Deployment status, system updates
- **Success** ✅: Backup completion, service recovery

## 🚀 Automation Features

- **Automated Backups**: Daily snapshots with 7-day retention
- **OS Updates**: Mass upgrade capability across all containers
- **Resource Monitoring**: Automated alerts for 90%+ disk usage
- **Self-healing**: Automatic container restart and recovery procedures

## 📈 Infrastructure Metrics

- **Total Containers**: 28 (24 original + 4 advanced monitoring)
- **Memory Allocation**: 30.75GB optimized (99% host utilization)
- **Storage**: 10TB shared data, optimized backup storage (103GB freed)
- **Observability**: Enterprise-grade with centralized logging and intelligent alerting
- **Uptime**: 99.9% availability with proactive monitoring and notifications

---

> **Homelab Philosophy**: Embrace Infrastructure as Code principles while maintaining the flexibility and learning opportunities that make homelab environments special. This GitOps approach provides enterprise-grade automation without sacrificing the ability to experiment and grow.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — see the [LICENSE](LICENSE) file for details.
