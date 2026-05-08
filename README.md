# Glendza Home

Personal homelab/server automation for private services, deployed with Ansible.

This repo manages my small private server stack: app hosting, media apps, auth, DNS, reverse proxy, networking, and hardening.

## Prerequisites

- Ansible installed locally.
- Access to the target host from your local machine.
- A vault password file at `.ansible-vault-password` (used by most Make targets).
- Encrypted config files such as `inventory.ini` and `vars/host_secrets.yml`.
- `uv` installed locally (used to sync Python/Ansible dependencies from `pyproject.toml` + `uv.lock`).

The Makefile expects:

- Vault password file path: `.ansible-vault-password`
- Vault files edited via `ansible-vault`

## Quick Start

1. Sync local toolchain and dependencies:
   - `make setup`
2. Create or place your vault password in `.ansible-vault-password`.
3. Edit encrypted inventory and secrets:
   - `make edit-inventory`
   - `make edit-host-secrets`
4. Run setup targets you need (for example):
   - `make setup-docker`
   - `make setup-caddy`
   - `make setup-glendza`
   - `make setup-fail2ban`

## Dependency Management (uv)

This repo uses `uv` for Python dependency management. Dependencies are defined in `pyproject.toml` and pinned in `uv.lock`.

- `make uv-sync` - sync dependencies into local environment via `uv sync`.
- `make setup` - bootstrap command; currently runs `uv-sync`.

If you update dependency declarations, regenerate/update lock state with `uv` and re-run `make uv-sync`.

## Roles

Each role lives in `roles/<role_name>/`.

- [`roles/caddy`](roles/caddy): reverse proxy and TLS entrypoint.
- [`roles/cloudflare`](roles/cloudflare): Cloudflare-related integration/config.
- [`roles/docker`](roles/docker): Docker engine setup.
- [`roles/docker_network`](roles/docker_network): Docker network creation/management.
- [`roles/docker_registry`](roles/docker_registry): private Docker registry deployment.
- [`roles/dozzle`](roles/dozzle): container log viewer setup.
- [`roles/duckdns`](roles/duckdns): DuckDNS update service.
- [`roles/ensure_directory`](roles/ensure_directory): reusable directory creation role.
- [`roles/fail2ban`](roles/fail2ban): intrusion prevention and jail configuration.
- [`roles/filebrowser`](roles/filebrowser): filebrowser service deployment.
- [`roles/format_external_hdd`](roles/format_external_hdd): external HDD formatting/mount prep.
- [`roles/glendza`](roles/glendza): main website/service deployment.
- [`roles/jellyfin`](roles/jellyfin): media server deployment.
- [`roles/logrotate`](roles/logrotate): log retention and rotation settings.
- [`roles/paperless`](roles/paperless): paperless-ngx deployment.
- [`roles/postgres`](roles/postgres): PostgreSQL deployment and optional DB/user/grant management.
- [`roles/python`](roles/python): Python/runtime setup helpers.
- [`roles/redis`](roles/redis): Redis deployment/configuration.
- [`roles/miniflux`](roles/miniflux): Miniflux RSS reader deployment (Docker).
- [`roles/system`](roles/system): base system bootstrap/tuning.
- [`roles/tinyauth`](roles/tinyauth): authentication gateway.
- [`roles/transmission`](roles/transmission): torrent client deployment.
- [`roles/wireguard`](roles/wireguard): WireGuard VPN setup.

## Makefile Commands

### Vault Utilities

- `make setup` - bootstrap local environment (currently runs `uv sync`).
- `make uv-sync` - sync Python dependencies from lock file.
- `make vault-create` - create a new encrypted file.
- `make vault-edit` - edit an encrypted file.
- `make decrypt` - decrypt a file.
- `make view` - view decrypted content without editing.
- `make rekey` - change vault password on a file.
- `make edit-inventory` - edit `inventory.ini` via `ansible-vault`.
- `make edit-host-secrets` - edit `vars/host_secrets.yml` via `ansible-vault`.

### Playbook Targets

- `make setup-essentials` - install base packages and essential host configuration.
- `make setup-docker` - install and configure Docker engine.
- `make setup-docker-registry` - deploy private Docker registry service.
- `make purge-registry-images` - clean old images from private registry.
- `make setup-postgres` - deploy PostgreSQL service and optional managed users/databases.
- `make setup-miniflux` - deploy Miniflux RSS reader service.
- `make setup-filebrowser` - deploy filebrowser service.
- `make setup-paperless` - deploy paperless-ngx service.
- `make setup-jellyfin` - deploy Jellyfin media server.
- `make setup-tinyauth` - deploy tinyauth identity/auth layer.
- `make setup-caddy` - deploy Caddy reverse proxy and TLS config.
- `make setup-wireguard` - deploy and configure WireGuard VPN.
- `make setup-fail2ban` - deploy fail2ban jails and firewall actions.
- `make setup-logrotate` - configure log rotation policy.
- `make setup-format-external-hdd` - format and prepare external HDD.
- `make setup-glendza` - deploy the main Glendza app/service.
- `make security-status` - run security status/check playbook.
- `make inventory` - print decrypted Ansible inventory as YAML.
- `make generate-wireguard-peer` - generate WireGuard peer/client configuration.
