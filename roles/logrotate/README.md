# Logrotate Role

This role configures log rotation for services using the system's logrotate utility.

## Features

- Installs and configures logrotate package
- Ensures cron service is running (required for logrotate)
- Configures log rotation for multiple services
- Integrates with fail2ban by reloading jails after rotation
- Fully parameterized configuration
- Tests logrotate configurations

## Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `logrotate_services` | List of services to configure log rotation for | See examples below |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `logrotate_frequency` | How often to rotate logs | `"daily"` |
| `logrotate_rotate` | Number of rotated logs to keep | `7` |
| `logrotate_compress` | Whether to compress old logs | `true` |
| `logrotate_delaycompress` | Whether to delay compression | `true` |
| `logrotate_missingok` | Whether to ignore missing log files | `true` |
| `logrotate_notifempty` | Whether to not rotate empty logs | `true` |
| `logrotate_create_mode` | File permissions for new log files | `"644"` |
| `logrotate_create_owner` | Owner for new log files | `{{ docker_user \| default('root') }}` |
| `logrotate_create_group` | Group for new log files | `{{ docker_group \| default('root') }}` |
| `logrotate_reload_fail2ban` | Whether to reload fail2ban after rotation | `true` |
| `logrotate_install_package` | Whether to install logrotate package | `true` |
| `logrotate_ensure_cron` | Whether to ensure cron service is running | `true` |

## Service Configuration Structure

Each service in `logrotate_services` should have the following structure:

```yaml
logrotate_services:
  - name: "service_name"                    # Name for the logrotate config file
    log_directory: "/path/to/logs"          # Directory containing log files
    fail2ban_jails: ["jail1", "jail2"]     # List of fail2ban jails to reload (optional)
```

## Examples

### Basic Configuration

```yaml
logrotate_services:
  - name: "jellyfin"
    log_directory: "/var/log/jellyfin"
    fail2ban_jails: ["jellyfin"]
  
  - name: "filebrowser"
    log_directory: "/var/log/filebrowser"
    fail2ban_jails: ["filebrowser"]
```

### Advanced Configuration

```yaml
# Customize rotation settings
logrotate_frequency: "weekly"
logrotate_rotate: 14
logrotate_compress: false

logrotate_services:
  - name: "nginx-proxy-manager"
    log_directory: "/var/log/nginx-proxy-manager"
    fail2ban_jails: ["nginx-http-auth", "nginx-badbots", "nginx-noscript", "nginx-404"]
  
  - name: "paperless"
    log_directory: "/var/log/paperless"
    fail2ban_jails: ["paperless"]
```

### Service-Specific Overrides

```yaml
logrotate_services:
  - name: "high-volume-service"
    log_directory: "/var/log/high-volume"
    fail2ban_jails: ["service-jail"]
    # Override global settings for this service
    frequency: "hourly"
    rotate: 24
    compress: true
```

## Usage

Include this role in your playbook:

```yaml
- hosts: homeserver
  become: true
  roles:
    - role: logrotate
      vars:
        logrotate_services:
          - name: "jellyfin"
            log_directory: "/var/log/jellyfin"
            fail2ban_jails: ["jellyfin"]
```

## Dependencies

- `docker_user` and `docker_group` variables should be defined (usually from the docker role)
- fail2ban should be configured if using fail2ban integration

## Notes

- Log files are rotated daily by default
- Old logs are kept for 7 days by default
- Logs are compressed after rotation
- fail2ban jails are automatically reloaded after log rotation
- Configuration files are backed up before changes
- All configurations are tested with `logrotate -d` before deployment
