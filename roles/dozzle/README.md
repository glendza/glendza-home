# Dozzle

Deploys Dozzle as a Docker logs viewer behind `forward-proxy` auth mode.

## Deploy

Use the services playbook that includes this role, or include the role directly in a dedicated playbook.

Example role vars:

```yaml
- role: dozzle
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    docker_network: glendza_home_server
    dozzle_service_directory: /srv/docker/services/dozzle
    dozzle_volumes_directory: /srv/docker/volumes/dozzle
```

## Caddy Integration

Configure Dozzle host routing in `vars/host_secrets.yml` under `caddy`:

```yaml
caddy:
  public_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```

To protect Dozzle behind tinyauth, place it under `protected_sites` instead:

```yaml
caddy:
  protected_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```

## Main defaults

- `dozzle_level` (`info`)
# Dozzle

Deploys Dozzle as a Docker logs viewer behind `forward-proxy` auth mode.

## Deploy

Use the services playbook that includes this role, or include the role directly in a dedicated playbook.

Example role vars:

```yaml
- role: dozzle
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    docker_network: glendza_home_server
    dozzle_service_directory: /srv/docker/services/dozzle
    dozzle_volumes_directory: /srv/docker/volumes/dozzle
```

## Main defaults

- `dozzle_level` (`info`)
# Dozzle

Dozzle is exposed through the Caddy role.

Configure the host in `vars/host_secrets.yml` under `caddy`:

```yaml
caddy:
  public_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```

To protect Dozzle behind tinyauth, place it under `protected_sites` instead:

```yaml
caddy:
  protected_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```
# Dozzle

Dozzle is exposed through the Caddy role.

Configure the host in `vars/host_secrets.yml` under `caddy`:

```yaml
caddy:
  public_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```

To protect Dozzle behind tinyauth, place it under `protected_sites` instead:

```yaml
caddy:
  protected_sites:
    - host: "logs.example.com"
      upstream: "dozzle:8080"
```