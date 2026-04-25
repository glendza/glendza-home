# Caddy

Deploys Caddy as the reverse proxy with automatic HTTPS and OIDC `forward_auth` support.

## Deploy

Use the dedicated playbook (or `make setup-caddy` from the repo root):

```bash
ansible-playbook playbooks/setup_caddy.yml --vault-password-file .ansible-vault-password
```

## Required `vars/host_secrets.yml` structure

Define top-level `cloudflare` and `caddy` mappings:

```yaml
cloudflare:
  token: "your-cloudflare-dns-edit-token"

caddy:
  oidc_auth_domain: "auth.example.com"
  oidc_auth_upstream: "tinyauth:3000"
  oidc_auth_uri: "/api/auth/caddy"
  public_sites:
    - host: "status.example.com"
      upstream: "dozzle:8080"
  protected_sites:
    - host: "docs.example.com"
      upstream: "paperless-ngx:8000"
```

## Main defaults

- `caddy_image` (`caddy:2`)
- `caddy_container_name` (`caddy`)
- `caddy_http_port` (`80`)
- `caddy_https_port` (`443`)
- `caddy_service_directory` (`/opt/caddy`)
- `caddy_volumes_directory` (`/opt/caddy/volumes`)
- `caddy_config_directory` (`/opt/caddy/volumes/config`)
- `caddy_data_directory` (`/opt/caddy/volumes/data`)
- `caddy_log_directory` (`/var/log/caddy`)
- `caddy_access_log_file` (`/var/log/caddy/access.log`; set to `null` to log to stdout)
- `caddy_log_time_format` (`2006-01-02 15:04:05`)
- `caddy_network` (`glendza_home_server`)
- `caddy_manage_public_tls_certificates` (`true`)
- `caddy_redirect_http_to_https` (`true`)
- `caddy_use_cloudflare_dns_challenge` (`false`)
- `caddy_dns_challenge_propagation_delay` (`30s`)
- `caddy_dns_challenge_propagation_timeout` (`-1`, disables local propagation checks)
