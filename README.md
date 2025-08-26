# 🏠 Homelab GitOps Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/ansible-%23EE0000.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](https://www.proxmox.com/)
[![GitOps](https://img.shields.io/badge/GitOps-326CE5.svg?style=for-the-badge&logo=git&logoColor=white)](https://about.gitlab.com/topics/gitops/)

## Overview

Infrastructure as Code (IaC) and GitOps implementation for a 28-container Proxmox homelab featuring media services, advanced monitoring & observability, security, and business applications.

🔗 **Repository**: [https://github.com/piyush97/homelab-gitops](https://github.com/piyush97/homelab-gitops)

## 🏗️ Infrastructure

### Container Services (28 total)
- **🎬 Media Stack**: Plex, Sonarr, Radarr, qBittorrent, Prowlarr, Lidarr, Overseerr, FlareSolverr, AutoBrr
- **📊 Advanced Monitoring**: Grafana, Prometheus, **Loki**, **AlertManager**, **Blackbox Exporter**, **Promtail**, Uptime Kuma, PVE Exporter, Glance
- **🔒 Security**: SWAG, Wireguard, Vaultwarden, RustDesk
- **🏢 Business**: Odoo ERP, Paperless-ngx, Immich, File Server, Google Drive
- **🔔 Communication**: ntfy notifications

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
├── terraform/                 # Infrastructure as Code
│   ├── providers.tf           # Proxmox provider configuration
│   ├── variables.tf           # Global variables
│   ├── containers/            # Container definitions by category
│   │   ├── media-stack.tf     # Media services (Plex, Sonarr, etc.)
│   │   ├── monitoring.tf      # Grafana, Prometheus, Uptime Kuma
│   │   ├── security.tf        # SWAG, Wireguard, Vaultwarden
│   │   └── business.tf        # Odoo, Paperless-ngx
│   └── modules/               # Reusable Terraform modules
│       ├── lxc-container/     # Standard LXC container module
│       └── firewall-rules/    # Firewall configuration module
├── ansible/                   # Configuration management
│   ├── inventory/             # Host inventories
│   ├── playbooks/             # Deployment playbooks
│   ├── roles/                 # Reusable roles
│   └── group_vars/            # Group-specific variables
├── configs/                   # Application configurations
│   ├── docker-compose/        # Docker Compose files
│   ├── firewall/              # Firewall rules
│   └── monitoring/            # Monitoring configurations
└── .github/workflows/         # CI/CD automation
    ├── terraform-plan.yml     # Infrastructure planning
    ├── terraform-apply.yml    # Infrastructure deployment
    └── ansible-deploy.yml     # Configuration deployment
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