# Homelab Architecture

This page describes the **verified live layout**, not a promise that Terraform matches the running host. Runtime addresses and states can change; use Proxmox as the source of truth before making changes.

## Host and network

- Proxmox node: `piyushmehta`
- LAN: `192.168.0.0/24` on `vmbr0`; router: `192.168.0.1`
- Pi-hole (`192.168.0.23`) is DNS-only.
- Caddy provides reverse proxying.
- WireGuard container has LAN address `192.168.0.217` and tunnel interface `10.0.0.1/24`.

## Storage and media

- TrueNAS media is mounted on Proxmox and passed to Jellyfin.
- Jellyfin transcodes use `/vault`.
- The local ZFS mirror uses two 12 TB disks on native SATA.

## Selected services

| Service | CTID | Runtime address | State / notes |
|---|---:|---|---|
| Qdrant | 100 | `192.168.0.76` | Running |
| Home Assistant | 101 | `192.168.0.132` | Running in Docker |
| WireGuard | 103 | `192.168.0.217` | Running; tunnel `10.0.0.1/24` |
| Jellyfin | 104 | `192.168.0.33` | Running; TrueNAS media mounts |
| Pi-hole | 105 | `192.168.0.23` | Running; DNS only |
| Trilium | 106 | `192.168.0.106` | Running |
| Hermes Agent | 107 | `192.168.0.136` | Running |
| Actual Budget | 108 | `192.168.0.247` | Running |
| MQTT | 110 | DHCP; address not recorded | Running |
| Caddy | 111 | `192.168.0.97` | Running; reverse proxy |
| 9router | 113 | `192.168.0.45` | Running |
| Monitoring | 114 | DHCP; address not recorded | Running |
| Plex | 115 | `192.168.0.207` | Running |
| Redis | 116 | DHCP; address not recorded | Running |
| Immich | 117 | `192.168.0.111` | Running |
| qBittorrent | 204 | `192.168.0.43` | Running |

The complete container list, including stopped services, is in [`container-mapping.md`](container-mapping.md). Hardware/Proxmox version and external service exposure are omitted where not verified.
