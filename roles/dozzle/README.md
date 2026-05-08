# Dozzle

This role renders a Docker Compose stack for [Dozzle](https://github.com/amir20/dozzle), a web UI for live Docker container logs. It mounts the host Docker socket and a small persistent data directory for Dozzle state.

Paths, container identity, and image tag are expected from the playbook (see `playbooks/setup_dozzle.yml`). Typical deployments put the UI behind Caddy on port 8080 inside the stack (`dozzle:8080`) without publishing a host port.

## Role variables

| Variable | Required | Secret | Default | Description |
|----------|----------|--------|---------|-------------|
| `docker_user` | yes | no | — | POSIX owner for generated files and bind mounts. |
| `docker_group` | yes | no | — | POSIX group for generated files and bind mounts. |
| `dozzle_service_directory` | yes | no | — | Host directory for `compose.yml` (set in playbook). |
| `dozzle_data_directory` | yes | no | — | Host directory mounted at `/data` in the container (set in playbook). |
| `dozzle_image_tag` | yes | no | — | Image tag for `dozzle_image_repository` (set in playbook, e.g. `v10`). |
| `dozzle_container_name` | yes | no | — | Docker container name (set in playbook). |
| `dozzle_docker_networks` | yes | no | `[]` | Non-empty list of Docker networks the container joins (playbook usually overrides). |
| `dozzle_image_repository` | no | no | `amir20/dozzle` | Image repository on the registry. |
| `dozzle_restart_policy` | no | no | `unless-stopped` | Compose restart policy. |
| `dozzle_level` | no | no | `info` | Log level (`DOZZLE_LEVEL`). |
| `dozzle_auth_provider` | no | no | `forward-proxy` | `DOZZLE_AUTH_PROVIDER` when authenticating at the reverse proxy. |
| `dozzle_environment` | no | no | `{}` | Extra environment key/value pairs for the container. |
| `dozzle_port_mappings` | no | no | `[]` | If non-empty, publishes these host:container ports; if empty, only `expose: "8080"` is used for overlay networks. |

## Minimal inputs (required only)

```yaml
docker_user: "{{ username }}"
docker_group: "{{ username }}"
dozzle_service_directory: /srv/docker/services/dozzle
dozzle_data_directory: /srv/docker/volumes/dozzle/data
dozzle_image_tag: v10
dozzle_container_name: dozzle
dozzle_docker_networks:
  - glendza_home_server
```

## Defaults and required values

Optional tuning (`dozzle_level`, `dozzle_auth_provider`, `dozzle_environment`, `dozzle_port_mappings`) lives in `defaults/main.yml`. Directory paths, image tag, container name, and networks are not defaulted and must be supplied by the playbook so deployments stay explicit.

## Caddy integration

Dozzle listens on **8080 inside the Docker network**. With an empty `dozzle_port_mappings`, nothing is bound on the host; Caddy on the same network proxies to the container.

Public site (trust headers from Caddy; pair with `dozzle_auth_provider: forward-proxy` and your edge auth if needed):

```yaml
caddy:
  public_sites:
    - host: "logs.example.com"
      upstream: "http://dozzle:8080"
```

OIDC / Tinyauth-protected route:

```yaml
caddy:
  protected_sites:
    - host: "logs.example.com"
      upstream: "http://dozzle:8080"
```

**Ports:** keep Dozzle on the internal 8080 unless you need direct host access; then set `dozzle_port_mappings` (for example `"8080:8080"`) and adjust firewall and Caddy upstream accordingly.
