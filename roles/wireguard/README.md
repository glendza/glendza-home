# Wireguard VPN Role

This role sets up a Wireguard VPN server using Docker for secure network access.

## Features

- **Wireguard VPN Server**: Secure VPN server with configurable peers
- **Docker-based**: Easy deployment and management
- **Dynamic Peer Management**: Jinja2-based peer configuration generation
- **Flexible Networking**: Configurable subnets and network settings
- **Automatic Config Generation**: Server and client configs generated automatically

## Prerequisites

### Required Tools
- `wg` command-line tool for generating Wireguard keys
- Ansible vault for secure secret management
- Docker and Docker Compose

### Installing Wireguard Tools
```bash
# On Ubuntu/Debian
sudo apt install wireguard-tools

# On CentOS/RHEL
sudo yum install wireguard-tools

# On Arch/Manjaro
sudo pacman -S wireguard-tools

# On macOS
brew install wireguard-tools
```

## 🔐 Generating Required Secrets

### 1. Server Key Generation

```bash
# Create a temporary directory for key generation
mkdir -p /tmp/wireguard-keys && cd /tmp/wireguard-keys

# Generate server private key
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Display the keys (copy these to your vault file)
echo "=== SERVER KEYS ==="
echo "Server Private Key: $(cat server_private.key)"
echo "Server Public Key: $(cat server_public.key)"
echo ""

# Clean up temporary files
cd .. && rm -rf /tmp/wireguard-keys
```

### 2. Peer Configuration Generation

**Option A: Use the Local Playbook (Recommended)**
```bash
# Generate peer configs locally using your vault configuration
make generate-wireguard-peer

# The playbook automatically reads from wireguard.peers in your vault
# No need to manually specify peer details
```

**Option B: Manual Generation**
```bash
# Generate peer keys manually
wg genkey | tee peer_private.key | wg pubkey > peer_public.key

# Create peer config manually using the template structure
```

## 📝 Configuration File Structure

### Example `vars/host_secrets.yml`

```yaml
# ... existing code ...

wireguard:
  # Basic settings (optional - have sensible defaults)
  enabled: true
  port: 51820
  internal_subnet: "10.13.13.0"  # Server gets .1, peers get .2, .3, etc.
  allowed_ips: "0.0.0.0/0"
  persistent_keepalive: 25
  config_directory: "/srv/docker/volumes/wireguard"
  peer_dns: "1.1.1.1"
  peer_allowed_ips: "0.0.0.0/0"
  timezone: "Etc/UTC"
  server_url: ""
  
  # Container settings (optional - have sensible defaults)
  user_id: 1000
  group_id: 1000
  service_directory: "/srv/docker/services/wireguard"
  
  # REQUIRED CONFIGURATION (no defaults - must be set)
  server_private_key: "your-server-private-key-here"
  server_public_key: "your-server-public-key-here"
  server_endpoint: "your-server-public-ip-or-domain"
  
  # Networks Configuration (REQUIRED - supports multiple networks)
  networks:
    - "glendza_home_server"
    - "management_network"  # Optional additional network
  
  # Peer Configuration (REQUIRED - used by generate-wireguard-peer playbook)
  peers:
    - name: "laptop"
      private_key: "laptop-private-key-here"
      public_key: "laptop-public-key-here"
      ip: "10.13.13.2"
    - name: "phone"
      private_key: "phone-private-key-here"
      public_key: "phone-public-key-here"
      ip: "10.13.13.3"
    - name: "work-machine"
      private_key: "work-private-key-here"
      public_key: "work-public-key-here"
      ip: "10.13.13.4"

# ... existing code ...
```

### Playbook-Specific Configuration

The `generate-wireguard-peer` playbook supports additional configuration options that are separate from the role:

```yaml
# In your vault, you can optionally add:
wireguard:
  # ... role configuration ...
  
  # Playbook-specific options (optional)
  peer_output_dir: "/custom/path/for/peers"  # Customize output directory
```

**Note**: If `peer_output_dir` is not specified, the playbook defaults to `"./wireguard-peers"`.

**Note**: The `internal_subnet` value (e.g., "10.13.13.0") automatically becomes the server's IP (10.13.13.1). Peers are assigned sequential IPs starting from .2.

**Required vs Optional**: Security-sensitive values like keys and networks have no defaults and must be configured. Basic settings like ports and timezones have sensible defaults.

**Security Note**: Peer private keys are generated locally and never stored on the server. Only peer public keys are needed on the server.

**Peer Generation**: The `generate-wireguard-peer` playbook automatically reads from `wireguard.peers` in your vault and generates all peer configurations at once.

## 🚀 Quick Setup Guide

### 1. Generate All Required Keys
```bash
# Run the key generation commands above
# Copy all generated keys to your vault file
```

### 2. Update Your Vault File
```bash
make edit-host-secrets
# Add the wireguard section with your generated keys
```

### 3. Deploy Wireguard
```bash
make setup-wireguard
```

## 🔒 Security Best Practices

### Key Management
- **Never commit keys to version control**
- **Use Ansible vault for all sensitive data**
- **Rotate keys periodically** (recommended: every 6-12 months)
- **Store backup keys securely**

### Network Security
- **Use unique subnets** for different environments
- **Limit peer allowed IPs** when possible
- **Monitor VPN connections** regularly
- **Keep Wireguard software updated**

### VPN Security
- **Use strong cryptographic keys**
- **Monitor connection logs**
- **Regular security updates**
- **Firewall configuration** (UDP port 51820)

## 🆘 Troubleshooting

### Common Issues

#### Keys Not Working
- Ensure private/public key pairs match
- Check that keys are properly copied (no extra spaces)
- Verify server endpoint is reachable

#### VPN Connection Fails
- Check firewall rules (UDP port 51820)
- Verify server is listening on correct interface
- Check peer configuration files
- Ensure Docker container is running

#### Client Connection Issues
- Verify peer config files are generated correctly
- Check IP address conflicts
- Ensure DNS resolution works

### Debug Commands
```bash
# Check Wireguard status
sudo wg show

# Check container status
docker ps | grep wireguard

# View container logs
docker logs wireguard

# Test network connectivity
ping 10.13.13.1

# Check routing
ip route show
```

## Configuration

**Note**: All configuration values are defined in `defaults/main.yml`. No hardcoded defaults exist in Jinja templates.

### Wireguard Settings

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `wireguard_enabled` | No | `true` | Enable wireguard service |
| `wireguard_image` | No | `lscr.io/linuxserver/wireguard:latest` | Wireguard image |
| `wireguard_port` | No | `51820` | Wireguard port |
| `wireguard_internal_subnet` | No | `10.13.13.0` | Internal subnet |
| `wireguard_allowed_ips` | No | `0.0.0.0/0` | Allowed IPs for peers |
| `wireguard_persistent_keepalive` | No | `25` | Keepalive interval |
| `wireguard_networks` | **Yes** | `[]` | List of networks to connect to |

### Required Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `wireguard_server_private_key` | Server's private key | `"generated-private-key"` |
| `wireguard_server_public_key` | Server's public key | `"generated-public-key"` |
| `wireguard_server_endpoint` | Server's public endpoint | `"your-server-ip"` |
| `wireguard_networks` | List of network names | `["glendza_home_server"]` |
| `wireguard_peers` | List of peer configurations | See peer structure below |

### Peer Configuration Structure

Each peer in the `wireguard_peers` list should have:

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Unique peer identifier | `"laptop"`, `"phone"`, `"work-machine"` |
| `private_key` | Peer's private key | `"generated-private-key"` |
| `public_key` | Peer's public key | `"generated-public-key"` |
| `ip` | Peer's IP address | `"10.13.13.2"` |

### Container Settings

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `wireguard_user_id` | No | `1000` | Container user ID |
| `wireguard_group_id` | No | `1000` | Container group ID |
| `wireguard_service_directory` | No | `/srv/docker/services/wireguard` | Service directory |

### Optional Configuration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `wireguard_enabled` | Enable/disable Wireguard | `true` | `true` |
| `wireguard_port` | UDP port for Wireguard | `51820` | `51820` |
| `wireguard_internal_subnet` | Internal subnet | `"10.13.13.0"` | `"10.13.13.0"` |
| `wireguard_allowed_ips` | Allowed IPs for server | `"0.0.0.0/0"` | `"10.0.0.0/8"` |
| `wireguard_persistent_keepalive` | Keepalive interval | `25` | `25` |
| `wireguard_config_directory` | Config volume path | `/srv/docker/volumes/wireguard` | `/opt/wireguard` |
| `wireguard_peer_dns` | DNS for peers | `"1.1.1.1"` | `"8.8.8.8"` |
| `wireguard_peer_allowed_ips` | Allowed IPs for peers | `"0.0.0.0/0"` | `"10.0.0.0/8"` |
| `wireguard_timezone` | Container timezone | `"Etc/UTC"` | `"Etc/UTC"` |
| `wireguard_server_url` | Server URL | `""` | `"vpn.example.com"` |
| `wireguard_user_id` | Container user ID | `1000` | `1000` |
| `wireguard_group_id` | Container group ID | `1000` | `1000` |
| `wireguard_service_directory` | Service directory | `/srv/docker/services/wireguard` | `/opt/services` |

## Usage

### Basic Setup

```yaml
- role: wireguard
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    wireguard_network: glendza_home_server
```

### Custom Configuration

```yaml
- role: wireguard
  vars:
    docker_user: "{{ username }}"
    docker_group: "{{ username }}"
    wireguard_port: 51821
    wireguard_internal_subnet: "10.20.20.0"
    wireguard_peers:
      - name: "my-device"
        private_key: "my-private-key"
        public_key: "my-public-key"
        ip: "10.20.20.2"
```

## Client Connection

### 1. Copy Peer Config
```bash
# Copy the generated peer config to your client machine
scp username@your-server:/srv/docker/volumes/wireguard/peers/laptop.conf ./wg0.conf
```

### 2. Connect to VPN
```bash
# Start Wireguard interface
sudo wg-quick up ./wg0.conf

# Check connection status
sudo wg show

# Test connectivity
ping 10.13.13.1
```

### 3. Disconnect
```bash
# Stop Wireguard interface
sudo wg-quick down ./wg0.conf
```

## Integration with Other Services

### Docker Registry Access
Once connected to Wireguard, you can access services on the private network:

```bash
# Access Docker registry
docker login 10.13.13.1:5000

# Pull/push images
docker pull 10.13.13.1:5000/myimage:latest
```

### Other Services
- **SSH access** to private IPs
- **Web services** on private network
- **Database connections** securely
- **File sharing** within VPN

## Security Notes

- Wireguard runs on UDP port 51820 by default
- All traffic is encrypted end-to-end
- No username/password required - key-based authentication
- Consider using secrets management for sensitive keys

## Dependencies

- Docker and Docker Compose
- Ansible community.docker collection
- Proper network setup (external network should exist)
- Wireguard tools for key generation
