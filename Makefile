.ONESHELL:
.SHELL := /bin/bash
.PHONY: setup uv-sync vault-create vault-edit decrypt view rekey edit-inventory edit-host-secrets setup-essentials setup-docker setup-docker-registry purge-registry-images setup-filebrowser setup-paperless setup-jellyfin setup-tinyauth setup-caddy setup-wireguard setup-fail2ban setup-logrotate setup-format-external-hdd setup-glendza setup-postgres setup-dozzle setup-miniflux security-status inventory generate-wireguard-peer

ANSIBLE_PASSWORD_FILE=$(shell pwd)/.ansible-vault-password
KEYS_DIR := $(shell pwd)/keys

# Sync local Python dependencies via uv (uses pyproject.toml + uv.lock)
uv-sync:
	@uv sync

# Project bootstrap
setup: uv-sync

# Create a new encrypted vault file:
vault-create: setup
	@echo "Creating a new encrypted file..."
	export EDITOR="code --wait" && ansible-vault create $$(read -p "Enter file location: " loc && echo $$loc) --vault-password-file $(ANSIBLE_PASSWORD_FILE)

# Edit an existing encrypted vault file:
vault-edit: setup
	@echo "Editing an encrypted file..."
	export EDITOR="code --wait" && ansible-vault edit $$(read -p "Enter file location: " loc && echo $$loc) --vault-password-file $(ANSIBLE_PASSWORD_FILE)

# Decrypt a file:
decrypt: setup
	@echo "Decrypting a file..."
	ansible-vault decrypt $$(read -p "Enter file location: " loc && echo $$loc) --vault-password-file $(ANSIBLE_PASSWORD_FILE)

# View a file (decrypt without saving changes):
view: setup
	@echo "Viewing an encrypted file..."
	ansible-vault view $$(read -p "Enter file location: " loc && echo $$loc) --vault-password-file $(ANSIBLE_PASSWORD_FILE)

# Rekey a file (change password):
rekey: setup
	@echo "Rekeying an encrypted file..."
	ansible-vault rekey $$(read -p "Enter file location: " loc && echo $$loc) --vault-password-file $(ANSIBLE_PASSWORD_FILE)

edit-inventory:
	@echo "Editing inventory.ini ..."
	@export EDITOR="cursor --wait" && ansible-vault edit ./inventory.ini --vault-password-file $(ANSIBLE_PASSWORD_FILE)

edit-host-secrets:
	@export EDITOR="cursor --wait" && ansible-vault edit ./vars/host_secrets.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

# --- Playbook Targets ---

setup-essentials:
	@ansible-playbook playbooks/setup_essentials.yml --ask-become-pass --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-docker:
	@ansible-playbook playbooks/setup_docker.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-docker-registry:
	@ansible-playbook playbooks/setup_docker_registry.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

purge-registry-images:
	@ansible-playbook playbooks/purge_old_registry_images.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-garage:
	@ansible-playbook playbooks/setup_garage.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-soju:
	@ansible-playbook playbooks/setup_soju.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-actual:
	@ansible-playbook playbooks/setup_actual.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-filebrowser:
	@ansible-playbook playbooks/setup_filebrowser.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-paperless:
	@ansible-playbook playbooks/setup_paperless.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-jellyfin:
	@ansible-playbook playbooks/setup_jellyfin.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-tinyauth:
	@ansible-playbook playbooks/setup_tinyauth.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-caddy:
	@ansible-playbook playbooks/setup_caddy.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-wireguard:
	@ansible-playbook playbooks/setup_wireguard.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-fail2ban:
	@ansible-playbook playbooks/setup_fail2ban.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-logrotate:
	@ansible-playbook playbooks/setup_logrotate.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-format-external-hdd:
	@ansible-playbook playbooks/setup_format_external_hdd.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-glendza:
	@ansible-playbook playbooks/setup_glendza.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-frp:
	@ansible-playbook playbooks/setup_frp.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-postgres:
	@ansible-playbook playbooks/setup_postgres.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-dozzle:
	@ansible-playbook playbooks/setup_dozzle.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

setup-miniflux:
	@ansible-playbook playbooks/setup_miniflux.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

security-status:
	@ansible-playbook playbooks/security_status.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

inventory:
	@ansible-inventory --list -y --vault-password-file $(ANSIBLE_PASSWORD_FILE)

generate-wireguard-peer:
	@ansible-playbook playbooks/generate_wireguard_peers.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)

