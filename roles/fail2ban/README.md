# Fail2ban Role

This role installs and configures fail2ban to protect your server from brute force attacks and malicious activities.

## Features

- **SSH Protection**: Monitors SSH login attempts and bans IPs after repeated failures
- **Jellyfin Protection**: Custom filter for Jellyfin authentication failures
- **Filebrowser Protection**: Custom filter for Filebrowser authentication failures
- **Paperless-ngx Protection**: Custom filter for Paperless-ngx authentication failures
- **Glendza Protection**: Custom filter for Glendza authentication failures
- **Caddy Probe Protection**: Blocks common scanner paths returning repeated 404s
- **Configurable**: All settings are configurable through variables
- **Automatic Restart**: Service automatically restarts when configuration changes

## Requirements

- Ansible 2.9+
- Target system with systemd
- Package manager (apt, yum, dnf, etc.)

## Role Variables

### Required Variables

- `fail2ban_services`: Dictionary defining which services to protect with fail2ban

### Optional Variables

#### Global Settings
- `fail2ban_bantime`: Ban duration in seconds (default: 3600 - 1 hour)
- `fail2ban_findtime`: Time window to count failures (default: 600 - 10 minutes)
- `fail2ban_maxretry`: Maximum failures before ban (default: 5)
- `fail2ban_backend`: Backend to use (default: auto)
- `fail2ban_ignoreip`: IP addresses to never ban (default: "127.0.0.1/8 ::1")

#### Service Configuration
All services are configured through the unified `fail2ban_services` dictionary. Each service can have:

- `enabled`: Enable/disable the service (default: true)
- `port`: Ports to monitor (default: varies by service)
- `filter`: Filter name to use (default: varies by service)
- `logpath`: Log file path to monitor (default: varies by service)
- `maxretry`: Maximum failures before ban (default: varies by service)
- `custom_filter`: Whether to deploy a custom filter file (default: false)
- `failregex`: Custom regex pattern for failed logins (default: "")
- `ignoreregex`: Custom regex pattern to ignore (default: "")

#### Available Services
- **SSH**: Built-in sshd filter
- **Jellyfin**: Custom authentication filter
- **Filebrowser**: Custom authentication filter
- **Paperless-ngx**: Custom authentication filter
- **Glendza**: Custom authentication filter
- **Caddy probe 404**: Custom scan detection filter for reverse-proxy access logs

## Dependencies

None.

## Example Playbook

### Basic Usage
```yaml
- name: Install and configure fail2ban
  hosts: homeserver
  become: true
  vars:
    # Define which services to protect
    fail2ban_services:
      sshd:
        enabled: true
        port: "ssh"
        filter: "sshd"
        logpath: "/var/log/auth.log"
        maxretry: 5
        custom_filter: false
        failregex: ""
        ignoreregex: ""
      # Add more services as needed
  roles:
    - fail2ban
```

### Custom Configuration
```yaml
- name: Install and configure fail2ban with custom settings
  hosts: homeserver
  become: true
  vars:
    fail2ban_bantime: 7200  # 2 hours
    fail2ban_maxretry: 3    # Ban after 3 failures
    fail2ban_services:
      jellyfin:
        maxretry: 3  # Ban Jellyfin failures after 3 attempts
  roles:
    - fail2ban
```

### Disable Specific Jails
```yaml
- name: Install fail2ban with selective jails
  hosts: homeserver
  become: true
  vars:
    fail2ban_services:
      jellyfin:
        enabled: false
      filebrowser:
        enabled: false
  roles:
    - fail2ban
```

### Add Custom Service
```yaml
- name: Install fail2ban with custom service
  hosts: homeserver
  become: true
  vars:
    fail2ban_services:
      myapp:
        enabled: true
        port: "8080"
        filter: "myapp"
        logpath: "/var/log/myapp/access.log"
        maxretry: 3
        custom_filter: true
        failregex: "^.*Failed login from <HOST>.*$"
        ignoreregex: ""
  roles:
    - fail2ban
```

## Example host_secrets.yml

```yaml
# No secrets required for this role
# All configuration is done through playbook variables
# The fail2ban_services dictionary must be defined in your playbook
```

## Files Created

- `/etc/fail2ban/jail.local` - Main fail2ban configuration
- `/etc/fail2ban/filter.d/*.conf` - Custom filter files (only for services with `custom_filter: true`)

## Service Management

The role automatically:
- Installs fail2ban package
- Enables and starts the fail2ban service
- Ensures configured jail log directories/files exist before reloading fail2ban
- Restarts the service on every role run to keep runtime jail state consistent

## Monitoring

To check fail2ban status:
```bash
sudo fail2ban-client status
# Check specific jails (use the service names from your configuration)
sudo fail2ban-client status sshd
sudo fail2ban-client status jellyfin
sudo fail2ban-client status filebrowser
sudo fail2ban-client status paperless
sudo fail2ban-client status glendza
sudo fail2ban-client status caddy_probe_404
```

To unban an IP:
```bash
sudo fail2ban-client set sshd unbanip <IP_ADDRESS>
```

## Security Notes

- The role configures fail2ban to ignore localhost (127.0.0.1/8 and ::1)
- SSH protection is enabled by default
- Jellyfin protection monitors authentication failures
- Filebrowser protection monitors authentication failures
- Paperless-ngx protection monitors authentication failures
- Glendza protection monitors authentication failures
- Caddy probe protection monitors repeated suspicious 404 requests
- All jails can be individually enabled/disabled
- Ban times and retry counts are configurable

## Troubleshooting

### Check fail2ban logs
```bash
sudo journalctl -u fail2ban -f
```

### Verify configuration
```bash
sudo fail2ban-client reload
sudo fail2ban-client get sshd bantime
```

### Test filters
```bash
sudo fail2ban-regex /var/log/auth.log /etc/fail2ban/filter.d/sshd.conf
```
