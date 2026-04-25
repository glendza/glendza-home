# Glendza Role

Deploys the Glendza service using Docker Compose. This is my personal website built with Django and Wagtail CMS.

## Example `vars/host_secrets.yml`

```yaml
glendza:
  # Service configuration
  debug: false
  log_level: "INFO"
  
  # Django settings
  secret_key: "your-super-secret-django-secret-key-here"
  allowed_hosts: "app.example.com,localhost,127.0.0.1"
  csrf_trusted_origins: "https://app.example.com,http://localhost:8000,http://127.0.0.1:8000"
  db_location: "/app/data/app.db"
  django_admin_url: "admin/"
  wagtail_admin_url: "cms/"
  
  # Email settings
  email_backend: "django.core.mail.backends.smtp.EmailBackend"
  email_host: "smtp.gmail.com"
  email_port: 587
  email_use_tls: true
  email_host_user: "your-email@gmail.com"
  email_host_password: "your-app-password"
  email_use_ssl: false
  
  # Recaptcha settings
  recaptcha_public_key: "your-recaptcha-public-key"
  recaptcha_private_key: "your-recaptcha-private-key"
  
  # Docker registry configuration
  registry_url: "registry.example.com"  # Just the registry host
  image_name: "myapp"                   # The actual image name
  image_tag: "latest"             # Image tag to pull
  
  # Registry authentication (if needed)
  registry_auth_enabled: false
  registry_username: "your-registry-username"
  registry_password: "your-registry-password"
  
  # Network configuration
  docker_networks:
    - app_network
    - another_network
  
  # Directory paths
  service_directory: "/srv/docker/services/myapp"
  
  # Volume paths (optional)
  data_volume: "/srv/docker/volumes/myapp/data"
  logs_volume: "/var/log/myapp"
  static_volume: "/srv/docker/volumes/myapp/static"
```

## Important Notes

### Volume Configuration
- **Data volume**: Mounts to `/app/data` in container (contains database)
- **Logs volume**: Mounts to `/app/logs` in container
- **Static volume**: Mounts to `/app/static` in container (collected static files)
- All volumes are optional - if not specified, they won't be mounted
- When specified, volume directories are automatically created with correct GID ownership (match `glendza_user_gid`/`glendza_group_gid`)

### GID Configuration
The container runs as user/group GID 1000 by default. All volume directories are automatically owned by these GIDs to ensure proper permissions.

### Registry Configuration
- `registry_url` should be just the host (e.g., `registry.example.com`)
- `image_name` should be the actual image name (e.g., `myapp`)
- Final image will be: `registry.example.com/myapp:latest`
