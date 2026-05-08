# Postgres role

Sets up a PostgreSQL database service and its required runtime resources.

## Variables

| Variable | Required | Secret | Default | Description |
| --- | --- | --- | --- | --- |
| `docker_user` | Yes | No | none | Owner for rendered files/directories. |
| `docker_group` | Yes | No | none | Group for rendered files/directories. |
| `postgres_service_directory` | Yes | No | none | Host directory where `compose.yml` is rendered. |
| `postgres_data_directory` | Yes | No | none | Host directory mounted to `/var/lib/postgresql/data`. |
| `postgres_user` | Yes | Yes | none | `POSTGRES_USER` value passed to the container. |
| `postgres_password` | Yes | Yes | none | `POSTGRES_PASSWORD` value passed to the container. |
| `postgres_image_repository` | No | No | `postgres` | Docker image repository. |
| `postgres_image_tag` | No | No | `18` | Docker image tag. |
| `postgres_container_name` | No | No | `postgres` | Container name. |
| `postgres_restart_policy` | No | No | `unless-stopped` | Compose restart policy. |
| `postgres_port_mappings` | No | No | `["5432:5432"]` | Optional published host ports. |
| `postgres_expose_ports` | No | No | `["5432"]` | Optional internal exposed ports. |
| `postgres_docker_networks` | No | No | `[]` | Optional external Docker networks. |
| `postgres_admin_host` | No | No | `127.0.0.1` | Host used by `community.postgresql` management tasks. |
| `postgres_admin_port` | No | No | `5432` | Port used by `community.postgresql` management tasks. |
| `postgres_admin_database` | No | No | `postgres` | Maintenance DB for admin connection/grant tasks. |
| `postgres_managed_users` | No | Yes | `[]` | Optional users/roles to create (`name`, `password`, optional `role_attr_flags`). |
| `postgres_managed_databases` | No | No | `[]` | Optional DBs to create (`name`, `owner`, optional `grants` list). |

## Minimal role input example

```yaml
docker_user: "serveradmin"
docker_group: "serveradmin"
postgres_service_directory: "/srv/docker/services/postgres"
postgres_data_directory: "/srv/docker/volumes/postgres/data"
postgres_user: "milos"
postgres_password: "replace-with-strong-password"
```

## Optional managed users/databases example

```yaml
postgres_managed_users:
  - name: "app_user"
    password: "replace-with-app-user-password"
    role_attr_flags: "LOGIN"
  - name: "readonly_user"
    password: "replace-with-readonly-password"
    role_attr_flags: "LOGIN"

postgres_managed_databases:
  - name: "app_db"
    owner: "app_user"
    grants:
      - user: "app_user"
        privileges: "ALL"
      - user: "readonly_user"
        privileges: "CONNECT"
```

## Notes

- Required variables intentionally have no defaults and fail fast in role tasks.
- Optional compose blocks (`ports`, `expose`, `networks`, `volumes`, `environment`) are conditionally rendered only when relevant values exist.
- Optional user/database/grant management uses `community.postgresql` modules and installs `python3-psycopg2` on the target host when those lists are non-empty.
- This role does not require Caddy integration (Postgres is direct TCP, usually port `5432`).
