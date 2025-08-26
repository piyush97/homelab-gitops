# 🚀 Deployment Guide

🔗 **Repository**: [https://github.com/piyush97/homelab-gitops](https://github.com/piyush97/homelab-gitops)

Complete guide for deploying the homelab GitOps infrastructure from scratch.

## 📋 Prerequisites

### System Requirements
- **Proxmox VE**: Version 8.0+ with API access
- **Hardware**: 32GB+ RAM, 500GB+ storage recommended
- **Network**: Static IP configuration on management network
- **OS Templates**: Container templates available in Proxmox

### Required Tools
```bash
# Terraform (Infrastructure provisioning)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Ansible (Configuration management)
sudo apt update
sudo apt install ansible

# Git (Version control)
sudo apt install git

# Optional: Make (Task automation)
sudo apt install make
```

### Access Requirements
- **Proxmox API**: User with VM/Container management permissions
- **SSH Keys**: Configured for container access
- **Network Access**: Ability to reach container IPs
- **GitHub**: Repository access (if using CI/CD)

## 🔧 Initial Setup

### 1. Clone Repository
```bash
git clone https://github.com/piyush97/homelab-gitops.git
cd homelab-gitops
```

### 2. Configure Proxmox Access
Create `terraform/terraform.tfvars`:
```hcl
# Proxmox connection
proxmox_api_url      = "https://your-proxmox-host:8006/api2/json"
proxmox_api_user     = "terraform@pve"
proxmox_api_password = "your-secure-password"

# Infrastructure settings
target_node         = "your-node-name"
network_bridge      = "vmbr0"
primary_gateway     = "192.168.0.1"
vpn_gateway        = "10.10.10.1"
shared_data_storage = "data"
docker_storage     = "vault"
```

### 3. Validate Configuration
```bash
# Quick validation
make validate

# Or manual validation
./scripts/validate-infrastructure.sh
```

## 🏗️ Deployment Options

### Option 1: Full Automated Deployment
```bash
# Deploy everything at once
make deploy
```

### Option 2: Step-by-Step Deployment
```bash
# 1. Plan infrastructure changes
make plan

# 2. Apply infrastructure
make apply

# 3. Configure services
make ansible-deploy
```

### Option 3: Manual Deployment

#### Terraform (Infrastructure)
```bash
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan
```

#### Ansible (Configuration)
```bash
cd ansible

# Test connectivity
ansible all -m ping

# Deploy configurations
ansible-playbook playbooks/site.yml --diff
```

## 📊 Deployment Phases

### Phase 1: Core Infrastructure
**Containers**: Security, monitoring foundations
- SWAG (reverse proxy)
- Wireguard (VPN)
- Grafana (monitoring)
- Prometheus (metrics)

### Phase 2: Storage & Business
**Containers**: Critical data services
- File server (NAS)
- Immich (photos)
- Paperless-ngx (documents)
- Vaultwarden (passwords)

### Phase 3: Media Stack
**Containers**: Media automation services
- Plex (media server)
- qBittorrent (torrents)
- *arr stack (Sonarr, Radarr, Lidarr)
- Supporting services

### Phase 4: Additional Services
**Containers**: Remaining services
- ntfy (notifications)
- Odoo (ERP)
- Utility containers

## 🔍 Verification Steps

### 1. Infrastructure Status
```bash
# Check container status
make status

# Or manually
pct list
```

### 2. Service Health Checks
```bash
# Test service connectivity
ansible all -m shell -a "systemctl status docker" --limit media

# Check web services
curl -I http://192.168.0.243:3000  # Grafana
curl -I http://192.168.0.15:2283   # Immich
curl -I http://192.168.0.207:32400 # Plex
```

### 3. Network Validation
```bash
# Test primary network
ping 192.168.0.243  # Grafana

# Test VPN network (from VPN containers)
ansible qbittorrent -m shell -a "ping -c 3 10.10.10.1"
```

### 4. Storage Verification
```bash
# Check mount points
ansible all -m shell -a "df -h | grep -E '/(data|docker)'"

# Verify permissions
ansible all -m shell -a "ls -la /data /docker"
```

## 🔧 Troubleshooting

### Common Issues

#### Container Creation Fails
```bash
# Check Proxmox resources
pvesm status
pct list

# Verify template availability
pveam list local

# Check network configuration
brctl show
```

#### Ansible Connection Issues
```bash
# Test SSH connectivity
ansible all -m ping

# Check SSH configuration
ssh root@192.168.0.243

# Debug Ansible connectivity
ansible all -m setup --limit grafana -vvv
```

#### Service Configuration Problems
```bash
# Check container logs
pct enter 110  # Grafana container
systemctl status grafana-server
journalctl -u grafana-server -f

# Verify configurations
ansible-playbook playbooks/site.yml --check --diff --limit grafana
```

### Recovery Procedures

#### Roll Back Infrastructure
```bash
# Revert to previous state
git log --oneline
git checkout <previous-commit>
terraform plan
terraform apply
```

#### Recreate Individual Container
```bash
# Destroy specific container
terraform destroy -target=module.grafana

# Recreate container
terraform apply -target=module.grafana

# Reconfigure services
ansible-playbook playbooks/site.yml --limit grafana
```

## 🔐 Security Considerations

### Initial Security Setup
1. **Change default passwords** for all services
2. **Configure firewall rules** for exposed services
3. **Set up SSL certificates** via SWAG
4. **Enable fail2ban** where applicable
5. **Configure backup encryption** for sensitive data

### Network Security
```bash
# Review firewall rules
iptables -L -n

# Check open ports
nmap -sS 192.168.0.0/24

# Verify VPN configuration
wg show  # On Wireguard container
```

### Access Control
- **SSH keys only** - disable password authentication
- **VPN access** for remote management
- **Service-specific authentication** configured per application
- **Regular security updates** via automated procedures

## 📱 Monitoring Setup

### Configure Notifications
1. Install ntfy app on mobile device
2. Subscribe to homelab topics:
   - `homelab-critical` (🔴 urgent alerts)
   - `homelab-warning` (🟡 warnings)  
   - `homelab-info` (ℹ️ status updates)
   - `homelab-success` (✅ confirmations)

### Monitoring Dashboards
- **Grafana**: http://192.168.0.243:3000
- **Uptime Kuma**: http://192.168.0.181:3001
- **Glance**: http://192.168.0.44:61208

## 📈 Post-Deployment

### Optimization
1. **Monitor resource usage** - adjust container resources as needed
2. **Tune performance** - optimize configurations for your workload  
3. **Implement backups** - configure automated backup strategies
4. **Set up alerts** - configure monitoring thresholds

### Maintenance
- **Regular updates** via mass upgrade procedures
- **Backup verification** - test restore procedures
- **Security patches** - apply updates promptly
- **Capacity planning** - monitor growth trends

## 🎯 Success Criteria

✅ **All 24 containers running and accessible**  
✅ **Web services responding correctly**  
✅ **Monitoring dashboards populated with data**  
✅ **Notifications working on mobile device**  
✅ **VPN access functional for remote management**  
✅ **Storage mounts configured and accessible**  
✅ **Firewall rules protecting exposed services**  

## 📚 Additional Resources

- [Terraform Proxmox Provider Documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)

---

🎉 **Congratulations!** Your homelab is now fully automated with GitOps practices. All infrastructure changes can now be managed through Git commits and automated deployments.