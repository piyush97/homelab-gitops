# Homelab GitOps Infrastructure

[![CI](https://github.com/piyush97/homelab-gitops/actions/workflows/ci.yml/badge.svg)](https://github.com/piyush97/homelab-gitops/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Terraform and Ansible configuration for a Proxmox homelab. **The configuration in this repository is not a live inventory:** VMIDs and service settings may differ from the current host. Check [`docs/container-mapping.md`](docs/container-mapping.md) for the separately verified runtime inventory and configuration drift.

## Current environment

- Proxmox node: `piyushmehta`; LAN: `192.168.0.0/24`, bridge `vmbr0`, router `192.168.0.1`.
- Pi-hole (`192.168.0.23`) provides DNS only.
- Caddy is the reverse proxy. TrueNAS supplies mounted media; Jellyfin uses `/vault` for transcodes.
- Local ZFS mirror: 2 × 12 TB disks connected via native SATA.
- Live Proxmox inventory: 23 listed containers (16 running, 7 stopped); IPs and states can change.

## Repository

- `terraform/` — Proxmox LXC declarations; review carefully before applying because they do not match the live inventory in all cases.
- `ansible/` — host configuration and service roles.
- `docs/` — architecture, current runtime mapping, monitoring, and deployment notes.

Related writing: [ZFS recovery](https://piyushmehta.com/blog/zfs-saved-my-data-seagate-warranty) · [Reverse proxy migration](https://piyushmehta.com/blog/migrating-nginx-proxy-manager-to-swag)
