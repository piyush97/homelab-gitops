# Live Container Inventory

Verified from Proxmox CT configuration/runtime snapshot. This is a point-in-time inventory, not Terraform state. `DHCP; unknown` means no address was recorded in the snapshot. Confirm the current address/state in Proxmox before operating a service.

**23 containers listed: 16 running, 7 stopped.** The Terraform files are separate declarations and do not fully match this inventory; do not apply them as a reconciliation plan without reviewing the drift.

| CTID | Hostname / service | Runtime IP | State |
|---:|---|---|---|
| 100 | Qdrant | `192.168.0.76` | Running |
| 101 | Home Assistant | `192.168.0.132` | Running |
| 103 | WireGuard | `192.168.0.217` | Running; tunnel `10.0.0.1/24` |
| 104 | Jellyfin | `192.168.0.33` | Running |
| 105 | Pi-hole | `192.168.0.23` | Running; DNS only |
| 106 | Trilium | `192.168.0.106` | Running |
| 107 | Hermes Agent | `192.168.0.136` | Running |
| 108 | Actual Budget | `192.168.0.247` | Running |
| 110 | MQTT | DHCP; unknown | Running |
| 111 | Caddy | `192.168.0.97` | Running; reverse proxy |
| 112 | autobrr | DHCP; unknown | Stopped |
| 113 | 9router | `192.168.0.45` | Running |
| 114 | Monitoring | DHCP; unknown | Running |
| 115 | Plex | `192.168.0.207` | Running |
| 116 | Redis | DHCP; unknown | Running |
| 117 | Immich | `192.168.0.111` | Running |
| 118 | Paperclip | DHCP; unknown | Stopped |
| 128 | Paperless-ngx | `192.168.0.36` | Stopped |
| 201 | Prowlarr | `192.168.0.40` | Stopped |
| 202 | Sonarr | `192.168.0.41` | Stopped |
| 203 | Radarr | `192.168.0.42` | Stopped |
| 204 | qBittorrent | `192.168.0.43` | Running |
| 205 | Seerr | `192.168.0.44` | Stopped |

## Notes

- LAN: `192.168.0.0/24`, Proxmox bridge `vmbr0`, router `192.168.0.1`; Pi-hole is DNS-only.
- TrueNAS media is mounted on Proxmox and passed to Jellyfin. Jellyfin transcodes use `/vault`. Home Assistant runs in Docker.
- Local ZFS mirror: two 12 TB disks connected via native SATA.
- Terraform module names, VMIDs, IPs, and service identities elsewhere in this repo are not authoritative for the live host. Reconcile them separately before applying Terraform.
