# Docker Registry

This role sets up a Docker Registry with configurable storage and authentication.

## Features

- **Docker Registry**: Private container registry with configurable storage
- **Authentication**: Support for htpasswd authentication
- **Configurable**: Extensive configuration options
- **Flexible Networking**: Configurable network settings
- **Clean and Simple**: Focused solely on registry functionality

## Prerequisites

### Required Tools
- Docker and Docker Compose
- Ansible vault for secure secret management
- htpasswd utility for authentication (optional)

### Installing htpasswd Utility
```bash
# On Ubuntu/Debian
sudo apt install apache2-utils

# On CentOS/RHEL
sudo yum install httpd-tools

# On Arch/Manjaro
sudo pacman -S apache2-utils

# On macOS
brew install httpd
```

## 🔐 Generating Required Secrets

### HTTP Secret Generation

Generate a random secret for the registry:

```bash
# Generate a random 32-character secret
openssl rand -hex 32

# Or use a simple random string
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

### Registry Authentication (Optional)

If you want to enable basic authentication for the registry:

```bash
# Create htpasswd file with a user
htpasswd -cB htpasswd your_username
# Enter password when prompted

# Add additional users
htpasswd -B htpasswd another_username
```

## 📝 Configuration File Structure

### Example `vars/host_secrets.yml`

```yaml
# ... existing code ...

docker_registry:
  # Basic registry settings (optional - have sensible defaults)
  port: 5000
  image_version: "2"
  log_level: "info"
  delete_enabled: false
  timezone: "Etc/UTC"
  

  
  # REQUIRED CONFIGURATION (no defaults - must be set)
  storage_path: "/srv/docker/volumes/docker_registry"
  service_directory: "/srv/docker/services/docker_registry"
  network: "glendza_home_server"
  http_secret: "your-generated-32-char-secret-here"
  
  # Authentication (optional - have sensible defaults)
  auth_enabled: true
  auth_type: "htpasswd"
  auth_htpasswd_file: "/auth/htpasswd"
  auth_username: "admin"                    # Default username
  auth_password_hash: "your-hash-here"      # Override default password
  
  # Firewall (required - list of allowed subnets)
  allowed_subnets:
    - "10.13.13.0/24"  # Wireguard subnet
    - "192.168.1.0/24"  # Local network (optional)
  
  # Notifications (optional)
  notifications_enabled: false
  notification_url: "http://your-webhook-url.com/webhook"

# ... existing code ...
```

**Required vs Optional**: Security-sensitive values like storage paths, networks, and HTTP secrets have no defaults and must be configured. Basic settings like ports and timezones have sensible defaults.

## 🚀 Quick Setup Guide

### 1. Generate Required Secrets
```bash
# Generate HTTP secret and htpasswd file if needed
# Copy generated values to your vault file
```

### 2. Update Your Vault File
```bash
make edit-host-secrets
# Add the docker_registry section with your configuration
```

### 3. Deploy the Registry
```bash
make setup-docker-registry
```

## 🔒 Security Best Practices

### Registry Security
- **Use strong HTTP secrets**
- **Enable authentication** in production
- **Regular security updates** for registry images
- **Monitor access logs**
- **Use HTTPS** when possible

### Authentication Security
- **Strong passwords** for htpasswd users
- **Regular password rotation**
- **Limit user access** to necessary users only
- **Monitor failed login attempts**

## 🆘 Troubleshooting

### Common Issues

#### Registry Not Accessible
- Check if container is running: `docker ps | grep registry`
- Verify port configuration
- Check network connectivity
- View container logs: `docker logs docker_registry`

#### Authentication Issues
- Verify htpasswd file exists and is readable
- Check file permissions
- Ensure correct file path in configuration
- Test htpasswd file: `htpasswd -v htpasswd username`

### Debug Commands
```bash
# Check registry status
docker ps | grep registry

# Test registry connectivity
curl -v http://localhost:5000/v2/

# View container logs
docker logs docker_registry

# Check registry configuration
docker exec docker_registry cat /etc/docker/registry/config.yml
```

## Configuration

**Note**: All configuration values are defined in `defaults/main.yml`. No hardcoded defaults exist in Jinja templates.

### Docker Registry Settings

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `docker_registry_image_version` | No | `"2"` | Registry image version |
| `docker_registry_port` | No | `5000` | Port for registry access |
| `docker_registry_timezone` | No | `"Etc/UTC"` | Container timezone |
| `docker_registry_log_level` | No | `"info"` | Logging level |
| `docker_registry_delete_enabled` | No | `false` | Enable image deletion |

### Required Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `docker_registry_storage_path` | Storage path for images | `"/srv/docker/volumes/docker_registry"` |
| `docker_registry_service_directory` | Service directory | `"/srv/docker/services/docker_registry"` |
| `docker_registry_network` | Docker network name | `"glendza_home_server"` |
| `docker_registry_http_secret` | HTTP secret for registry | `"your-32-char-secret"` |
| `docker_registry_allowed_subnets` | List of allowed subnets | `["10.13.13.0/24", "192.168.1.0/24"]` |

### Authentication Settings

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `docker_registry_auth_enabled` | No | `true` | Enable authentication |
| `docker_registry_auth_type` | No | `"htpasswd"` | Authentication type |
| `docker_registry_auth_htpasswd_file` | No | `/auth/htpasswd` | Htpasswd file path |
| `docker_registry_auth_username` | No | `"admin"` | Default username |
| `docker_registry_auth_password_hash` | No | `"$2y$10$..."` | Default password hash (admin:password) |

### Container Settings

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|


### Notifications (Optional)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `docker_registry_notifications_enabled` | No | `false` | Enable notifications |
| `docker_registry_notification_url` | No | `"http://example.com/webhook"` | Webhook URL |

## Usage

### Basic Setup

```yaml
- role: docker_registry
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    docker_registry_network: glendza_home_server
```

### Custom Configuration

```yaml
- role: docker_registry
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    docker_registry_port: 5001
    docker_registry_auth_enabled: false
    docker_registry_log_level: "debug"
```

## Accessing the Registry

### Local Access
```bash
# Login to registry
docker login localhost:5000

# Tag and push images
docker tag myimage:latest localhost:5000/myimage:latest
docker push localhost:5000/myimage:latest

# Pull images
docker pull localhost:5000/myimage:latest
```

### Remote Access
```bash
# Login to remote registry
docker login your-server-ip:5000

# Use registry
docker pull your-server-ip:5000/myimage:latest
```

## ⚠️ Firewall Configuration

**Note**: Firewall configuration (ufw) has been disabled in this role due to potential conflicts and security concerns. Use the separate **Wireguard role** for secure network access instead.

## Integration with Wireguard

To access your registry securely over the internet, use the separate **Wireguard role**:

1. **Deploy Wireguard role** for secure VPN access
2. **Connect to VPN** from your client machines
3. **Access registry** through the secure tunnel

The registry will be accessible at `10.13.13.1:5000` when connected to Wireguard.

## 🧹 Registry Maintenance

### Automatic Image Cleanup

The project includes a maintenance playbook to automatically purge old, unused Docker images:

```bash
# Run cleanup (dry run mode - shows what would be deleted)
make purge-registry-images

# Or run directly with ansible-playbook
ansible-playbook playbooks/purge_old_registry_images.yml --vault-password-file .ansible-vault-password
```

#### What the cleanup does:
- **Scans all repositories** in your Docker Registry
- **Identifies images older than 5 days** (configurable)
- **Deletes old manifests** to free up space
- **Runs garbage collection** to reclaim disk space
- **Supports dry-run mode** for safe testing

#### Configuration options:
```yaml
# In the playbook, you can modify:
days_old: 5          # Age threshold for deletion
dry_run: false       # Set to true for testing without deleting
```

#### Safety features:
- **Dry-run mode** available for testing
- **Authentication support** for secure registries
- **Retry logic** for network resilience
- **Detailed logging** of all operations
- **Garbage collection** after deletion

#### When to run:
- **Weekly maintenance** to prevent disk space issues
- **Before major deployments** to ensure clean state
- **When registry storage** is running low
- **As part of automated** maintenance schedules

## Security Notes

- The registry runs on port 5000 by default
- Authentication is enabled by default
- Consider using secrets management for sensitive keys
- Use in combination with Wireguard role for secure remote access

## Dependencies

- Docker and Docker Compose
- Ansible community.docker collection
- Proper network setup (external network should exist)
- htpasswd utility for authentication (optional)
