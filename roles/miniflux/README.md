# Miniflux role

Sets up a Miniflux RSS service and its required runtime resources.

## Variables

| Variable | Required | Secret | Default | Description |
| --- | --- | --- | --- | --- |
| `docker_user` | Yes | No | none | Owner for rendered files/directories. |
| `docker_group` | Yes | No | none | Group for rendered files/directories. |
| `miniflux_service_directory` | Yes | No | none | Host directory where `compose.yml` and `.env` are rendered. |
| `miniflux_image_tag` | Yes | No | none | Docker image tag. |
| `miniflux_container_name` | Yes | No | none | Container name. |
| `miniflux_database_url` | Yes | Yes | none | Miniflux PostgreSQL DSN (`DATABASE_URL`). |
| `miniflux_admin_username` | Yes | Yes | none | Initial admin username (`ADMIN_USERNAME`). |
| `miniflux_admin_password` | Yes | Yes | none | Initial admin password (`ADMIN_PASSWORD`). |
| `miniflux_image_repository` | No | No | `miniflux/miniflux` | Docker image repository. |
| `miniflux_restart_policy` | No | No | `unless-stopped` | Compose restart policy. |
| `miniflux_port_mappings` | No | No | `[]` | Optional published host ports. |
| `miniflux_docker_networks` | No | No | `[]` | Optional external Docker networks. |
| `miniflux_run_migrations` | No | No | `true` | Run DB migrations at startup (`RUN_MIGRATIONS`). |
| `miniflux_create_admin` | No | No | `true` | Create initial admin user (`CREATE_ADMIN`). |
| `miniflux_healthcheck_enabled` | No | No | `true` | Enable Miniflux internal healthcheck command. |

## Minimal role input example

```yaml
docker_user: "serveradmin"
docker_group: "serveradmin"
miniflux_service_directory: "/srv/docker/services/miniflux"
miniflux_image_tag: "latest"
miniflux_container_name: "miniflux"
miniflux_database_url: "postgres://miniflux:replace-with-password@postgres/miniflux?sslmode=disable"
miniflux_admin_username: "admin"
miniflux_admin_password: "replace-with-strong-admin-password"
```

## Notes

- Required variables intentionally have no defaults and fail fast in role tasks.
- `DATABASE_URL` should point to your Postgres service on a shared Docker network.
- With `miniflux_create_admin: true`, Miniflux creates the admin user on startup when missing.

## Caddy integration

Miniflux listens on **8080** in-container. You can either expose a host port directly or keep it internal and front it with Caddy.

Public route example:

```yaml
caddy:
  public_sites:
    - host: "feeds.example.com"
      upstream: "http://miniflux:8080"
```

Protected route example:

```yaml
caddy:
  protected_sites:
    - host: "feeds.example.com"
      upstream: "http://miniflux:8080"
```

Ports: if Caddy fronts Miniflux on a shared Docker network, host port mapping is optional. If you need direct host access, set `miniflux_port_mappings` (for example, `"80:8080"`).
