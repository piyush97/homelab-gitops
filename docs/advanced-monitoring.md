# 🔍 Advanced Monitoring & Observability

🔗 **Repository**: [https://github.com/piyush97/homelab-gitops](https://github.com/piyush97/homelab-gitops)

Comprehensive observability stack with centralized logging, advanced alerting, and external monitoring.

## 📊 Enhanced Monitoring Architecture

### New Components Added
```
┌─────────────────────────────────────────────────────────────┐
│                    Advanced Observability Stack             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Grafana   │    │ Prometheus  │    │ AlertManager│     │
│  │  Dashboard  │◄───┤   Metrics   │◄───┤   Alerting  │     │
│  │             │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         ▲                   ▲                   ▲           │
│         │                   │                   │           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │    Loki     │    │  Blackbox   │    │   Promtail  │     │
│  │    Logs     │    │  Exporter   │    │Log Shipping │     │
│  │             │    │ External    │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🆕 New Monitoring Containers

### Container 130: Loki (Log Aggregation)
- **IP**: 192.168.0.200
- **Ports**: 3100 (HTTP), 9095 (gRPC)
- **Purpose**: Centralized log collection and storage
- **Resources**: 2GB RAM, 2 cores

**Key Features**:
- 31-day log retention
- High-performance log ingestion
- Integration with Grafana dashboards
- Alert rule evaluation

### Container 131: AlertManager (Advanced Alerting)
- **IP**: 192.168.0.201
- **Ports**: 9093 (WebUI), 9094 (Cluster)
- **Purpose**: Alert routing and notification management
- **Resources**: 512MB RAM, 1 core

**Key Features**:
- Intelligent alert grouping and deduplication
- Multiple notification channels
- Integration with ntfy for mobile alerts
- Silence and inhibition rules

### Container 132: Blackbox Exporter (External Monitoring)
- **IP**: 192.168.0.202
- **Port**: 9115
- **Purpose**: External endpoint monitoring and health checks
- **Resources**: 256MB RAM, 1 core (Alpine)

**Key Features**:
- HTTP/HTTPS endpoint monitoring
- TCP port connectivity checks
- ICMP ping monitoring
- SSL certificate expiry tracking

### Container 133: Promtail (Log Shipping)
- **IP**: 192.168.0.204
- **Port**: 9080
- **Purpose**: Log collection and forwarding to Loki
- **Resources**: 512MB RAM, 1 core (Alpine)

**Key Features**:
- Efficient log tailing and parsing
- Label extraction and enrichment
- Multiple log source support
- Real-time log streaming

## 📈 Enhanced Observability Features

### 1. Centralized Logging
**Log Sources**:
- System logs from all 28 containers
- Application logs (Docker, services)
- Security logs (auth, firewall)
- Infrastructure logs (Proxmox, network)

**Log Management**:
- Structured logging with labels
- Log parsing and enrichment
- Retention policies (31 days)
- Full-text search capabilities

### 2. Advanced Alerting
**Alert Categories**:

#### 🔴 Critical Alerts
- Service unavailability (Plex, Grafana, Immich)
- Container failures or crashes
- Disk space critically low (<10%)
- Memory exhaustion

#### 🟡 Warning Alerts
- High resource utilization (>80%)
- Slow response times
- Disk space low (<20%)
- System service degradation

#### ℹ️ Info Alerts
- Deployment completions
- Backup status updates
- System maintenance windows
- Configuration changes

### 3. External Monitoring
**Monitored Endpoints**:
- Web services (HTTP/HTTPS)
- API endpoints
- Database connections
- Network services

**Health Checks**:
- Response time monitoring
- Status code validation
- SSL certificate expiry
- Service dependency tracking

## 🎯 Alerting Rules Configuration

### Infrastructure Alerts
```yaml
# Memory pressure
- alert: HostOutOfMemory
  expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
  labels:
    severity: warning

# Disk space
- alert: HostOutOfDiskSpace
  expr: (node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes < 10
  labels:
    severity: warning

# High CPU load
- alert: HostHighCpuLoad
  expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
  labels:
    severity: warning
```

### Service Availability Alerts
```yaml
# Critical services
- alert: PlexDown
  expr: probe_success{instance="http://192.168.0.207:32400"} == 0
  for: 5m
  labels:
    severity: critical

- alert: ImmichDown
  expr: probe_success{instance="http://192.168.0.15:2283"} == 0
  for: 5m
  labels:
    severity: critical
```

## 📱 Notification Integration

### ntfy Integration
AlertManager is configured to send notifications to your existing ntfy server:

**Notification Flow**:
```
Alert Triggered → AlertManager → ntfy Server → iPhone App
```

**Channel Mapping**:
- **Critical**: `homelab-critical` (🔴 immediate)
- **Warning**: `homelab-warning` (🟡 grouped)
- **Info**: `homelab-info` (ℹ️ digest)

## 🎨 Enhanced Dashboards

### New Grafana Data Sources
- **Loki**: Log analysis and correlation
- **Enhanced Prometheus**: More detailed metrics

### Dashboard Categories

#### 1. Infrastructure Overview
- Host resource utilization
- Container health and performance
- Network and storage metrics
- Service dependency maps

#### 2. Application Performance
- Response times and throughput
- Error rates and availability
- Resource consumption trends
- User activity patterns

#### 3. Log Analysis
- Real-time log streaming
- Error log aggregation
- Security event correlation
- Application debugging

#### 4. Alert Management
- Active alerts dashboard
- Alert history and trends
- Notification delivery status
- Silence and escalation tracking

## 🚀 Deployment Guide

### 1. Infrastructure Deployment
```bash
# Deploy new monitoring containers
cd terraform
terraform plan -target=module.loki -target=module.alertmanager -target=module.blackbox_exporter -target=module.promtail
terraform apply

# Configure services
cd ../ansible
ansible-playbook playbooks/site.yml --tags monitoring
```

### 2. Verification Steps
```bash
# Check service status
curl http://192.168.0.200:3100/ready        # Loki
curl http://192.168.0.201:9093/-/healthy    # AlertManager
curl http://192.168.0.202:9115/metrics      # Blackbox Exporter
curl http://192.168.0.204:9080/ready        # Promtail (if exposed)

# Test alerting
# Trigger a test alert to verify notification flow
```

### 3. Access URLs
- **Loki**: http://192.168.0.200:3100
- **AlertManager**: http://192.168.0.201:9093
- **Blackbox Exporter**: http://192.168.0.202:9115
- **Enhanced Grafana**: http://192.168.0.243:3000 (now with logs)

## 📊 Monitoring Metrics

### Container Count Summary
| Category | Original | Added | Total |
|----------|----------|-------|-------|
| Monitoring | 5 | 4 | 9 |
| Total Homelab | 24 | 4 | **28** |

### Resource Allocation
**Additional Resources**:
- **Memory**: +3.25GB (Loki: 2GB, AlertManager: 512MB, others: 768MB)
- **Storage**: +18GB (distributed across containers)
- **Network**: 4 new static IPs (192.168.0.200-204)

## 🔧 Advanced Configuration

### Log Pipeline Configuration
```yaml
# Promtail scrape configs
scrape_configs:
  - job_name: system_logs
    static_configs:
      - targets: [localhost]
        labels:
          job: system_logs
          __path__: /var/log/*.log
          
  - job_name: docker_logs
    static_configs:
      - targets: [localhost]
        labels:
          job: docker_logs
          __path__: /docker/*/logs/*.log
```

### Alert Routing Rules
```yaml
# AlertManager routing
route:
  group_by: [alertname, cluster, service]
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: homelab-notifications

receivers:
  - name: homelab-notifications
    webhook_configs:
      - url: http://192.168.0.124/homelab-critical
        send_resolved: true
```

## 🎯 Benefits Achieved

### 1. **Complete Visibility**
- End-to-end observability across all services
- Correlated metrics, logs, and traces
- Real-time health monitoring

### 2. **Proactive Alerting**
- Intelligent alert routing and grouping
- Mobile notifications for critical issues
- Predictive failure detection

### 3. **Operational Excellence**
- Centralized troubleshooting with logs
- Historical analysis and trending
- Automated health checks

### 4. **Performance Insights**
- Service dependency mapping
- Resource optimization opportunities
- Capacity planning data

## 🔮 Next Steps

### Phase 2 Enhancements
1. **Jaeger Tracing**: Distributed request tracing
2. **Custom Metrics**: Application-specific monitoring
3. **Log Alerting**: Alert on specific log patterns
4. **Dashboard Automation**: Auto-generated service dashboards

### Advanced Features
- **Machine Learning**: Anomaly detection algorithms
- **Chaos Engineering**: Automated resilience testing
- **SLI/SLO Tracking**: Service level objective monitoring
- **Cost Optimization**: Resource usage optimization

Your homelab now has enterprise-grade observability capabilities with comprehensive monitoring, alerting, and logging! 🎉