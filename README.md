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

## Infrastructure diagram

Full architecture generated with [Archify](https://github.com/tt-a1i/archify), based on the documented runtime snapshot and repository automation. Click the image for the full-resolution SVG.

[![Homelab architecture: Internet and LAN access, Proxmox networking, DNS, reverse proxy, VPN, storage, all 23 containers, and Terraform/Ansible automation](.archify/architecture-homelab-20261008-201746/homelab.svg)](.archify/architecture-homelab-20261008-201746/homelab.svg)

[Interactive diagram](.archify/architecture-homelab-20261008-201746/homelab.html) · [Editable diagram source](.archify/architecture-homelab-20261008-201746/candidate.json)

Download the HTML and open it locally for zoom, search, source references, light/dark themes, and image exports. GitHub displays the SVG directly; it does not run the HTML viewer.

- **Access:** the router connects the LAN to `vmbr0`. Clients use Pi-hole for DNS and Caddy for reverse-proxy requests; WireGuard provides a separate tunnel network.
- **Services:** all 23 containers include their CTIDs and recorded addresses. Running applications and stopped containers have separate groups; unknown DHCP addresses remain explicit.
- **Storage:** TrueNAS media passes through Proxmox to Jellyfin, which uses `/vault` for transcodes. The local 2 × 12 TB ZFS mirror is shown separately because its relationship to those mounts is undocumented.
- **Automation:** GitHub Actions validates configuration and supports manual Terraform deployment on a self-hosted runner, followed by optional Ansible configuration. These declarations differ from the runtime inventory.

Arrows show documented network, storage, and automation paths. Groups express placement and inventory state, not inferred application dependencies. Exact Caddy upstreams, public exposure, storage mount protocol, and the live monitoring stack are not recorded.

Container states and addresses are a snapshot; confirm them in Proxmox before making changes. Full inventory: [`docs/container-mapping.md`](docs/container-mapping.md). Architecture notes: [`docs/architecture.md`](docs/architecture.md).

## Repository

- `terraform/` — Proxmox LXC declarations; review carefully before applying because they do not match the live inventory in all cases.
- `ansible/` — host configuration and service roles.
- `docs/` — architecture, current runtime mapping, monitoring, and deployment notes.

Related writing: [ZFS recovery](https://piyushmehta.com/blog/zfs-saved-my-data-seagate-warranty) · [Reverse proxy migration](https://piyushmehta.com/blog/migrating-nginx-proxy-manager-to-swag)
