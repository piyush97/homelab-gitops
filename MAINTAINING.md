# Maintaining homelab-gitops

Runbook for maintaining this Infrastructure-as-Code (IaC) repository:
Terraform (Proxmox) + Ansible (service configuration), deployed to a
28-container Proxmox homelab.

## Repository layout

| Path | Purpose |
|------|---------|
| `terraform/` | Proxmox provider config, variables, LXC container module and per-stack definitions (`containers/*.tf`) |
| `ansible/` | Inventory (`inventory/hosts.yml`), playbooks, roles, and task files |
| `.github/workflows/ci.yml` | PR/push validation: `terraform fmt/init/validate` + `ansible-inventory` + `ansible-playbook --syntax-check` |
| `.github/workflows/terraform-validate.yml` | Path-scoped Terraform validation + plan dry-run (no credentials required) |
| `.github/workflows/drift-detection.yml` | Scheduled daily drift check against live infrastructure (credentials required) + Trivy config scan |
| `.github/workflows/deploy.yml` | Manual (workflow_dispatch) plan/apply/destroy against the homelab |
| `.github/workflows/stale.yml` | Weekly stale labeler for issues (60d) and PRs (30d) — never auto-closes |
| `.github/dependabot.yml` | Weekly dependency PRs for Terraform providers/modules and GitHub Actions |

## Validation commands (run before opening a PR)

Terraform (from repo root — mirrors `ci.yml`):

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate
```

> `terraform validate` needs **no credentials**: `-backend=false` skips remote
> state, and all variables except `proxmox_api_password` have defaults. Only
> `plan`/`apply` need real Proxmox credentials.

Ansible (from repo root):

```bash
cd ansible
ansible-inventory --list --yaml          # validates inventory
ansible-playbook playbooks/site.yml --syntax-check
```

Both gates run automatically in `ci.yml` on every push/PR.

## Drift detection

`drift-detection.yml` runs **daily at 06:00 UTC** (`schedule` cron) and can be
triggered manually via **Actions → Infrastructure Drift Detection → Run
workflow**.

It has two jobs:

1. **drift-check** — `terraform init` + `terraform plan -detailed-exitcode`
   against live infrastructure:
   - exit 0 → no drift (success notification, if webhook configured)
   - exit 2 → drift detected → drift report artifact (`drift-report.md`,
     `drift-output.txt`, 30-day retention) + webhook notification
   - exit 1 → plan error (missing credentials/state) → step reports
     `skipped`, workflow stays green with a warning
2. **security-scan** — Trivy config scan (SARIF) uploaded as code-scanning
   alert (CodeQL upload-sarif).

### Prerequisites for a live drift check

The plan step needs all three secrets **and** a real state file:

- **Secrets** (repo Settings → Secrets and variables → Actions):
  - `PROXMOX_API_URL` (e.g. `https://pve.example.com:8006/api2/json`)
  - `PROXMOX_API_USER` (e.g. `terraform@pve`)
  - `PROXMOX_API_PASSWORD`
  - Optional: `NOTIFICATION_WEBHOOK_URL` (replaces the hardcoded
    `192.168.0.124` webhook that the original workflow used; without it the
    notify steps skip).
- **State**: `terraform init` in this workflow runs with `-backend=false`, so
  plan compares against an empty local state. For a *meaningful* drift diff,
  configure a real backend (e.g. S3) in `terraform/providers.tf` and store the
  statefile there. Until then the check validates that the configuration still
  plans cleanly against the Proxmox API.

### Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `drift-check` job never runs ("cancelled") | Workflow used `runs-on: self-hosted` but no self-hosted runner is registered — this auto-disabled the workflow in Oct 2025. Fixed 2026-08: now `ubuntu-latest`. |
| `security-scan` always failed | `aquasecurity/trivy-action@master` (unpinned) + `codeql-action/upload-sarif@v2` (deprecated, GitHub started rejecting it Aug 2025). Fixed 2026-08: pinned `trivy-action@v0.36.0` + `upload-sarif@v3` + `exit-code: '1'`. |
| Plan step exits 1 ("Error running terraform plan") | Missing `PROXMOX_API_*` secrets or no state — check repo secrets; plan is intentionally non-fatal (step reports `skipped`). |
| Dependabot can't find Terraform updates | No `.terraform.lock.hcl` is committed (gitignored). Dependabot still proposes provider/module version bumps from `required_providers`; commit the lockfile if you want hash-pinned, reproducible updates. |
| Notify steps fail | `NOTIFICATION_WEBHOOK_URL` unset — set the secret or accept the skip. |

## Dependency updates (Dependabot)

`.github/dependabot.yml` opens **weekly (Monday)** PRs, max 5 open at a time:

- **Terraform** ecosystem for `terraform/` — provider (`telmate/proxmox`) and
  module updates, labelled `dependencies`.
- **GitHub Actions** ecosystem for `.github/workflows/` — action version bumps
  (checkout, setup-terraform, stale, trivy-action, upload-sarif...), labelled
  `dependencies`.

Dependabot PRs are exempt from the stale labeler (`exempt-pr-labels:
dependencies`). Review and merge them like any other PR — CI
(`ci.yml` + `terraform-validate.yml`) gates every one. No Docker or pip
ecosystems are configured because the repo has no `Dockerfile` /
`requirements.txt`.

## Issue/PR hygiene (stale bot)

`stale.yml` runs weekly (Monday 09:00 UTC):

- Issues inactive 60 days → labelled `stale` (never auto-closed:
  `days-before-issue-close: -1`).
- PRs inactive 30 days → labelled `stale` (never auto-closed; Dependabot PRs
  exempt via `dependencies` label).

## Checklist for a routine maintenance PR

1. `git checkout main && git pull`
2. Make the change (Terraform/Ansible/CI)
3. Run the validation commands above locally
4. Push a feature branch, open a PR against `main`
5. Wait for CI: `Terraform Validation` (ci.yml), `Ansible Validation`,
   `Terraform Validation` (terraform-validate.yml)
6. Merge squash + delete branch; drift-detection runs on schedule only (it
   never runs on PRs), so verify it manually via **workflow_dispatch** after
   credential/state changes
