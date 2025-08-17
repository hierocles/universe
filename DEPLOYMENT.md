# NixOS Deployment Guide

This guide covers deploying your NixOS configuration using `deploy-rs` with `disko` for disk management.

## Prerequisites

1. **Development Environment**
   ```bash
   nix develop  # Enters shell with deployment tools
   ```

2. **SSH Access**
   - Ensure SSH key-based authentication is set up
   - Target machine should be accessible via SSH
   - Root access required for initial deployment
   - Target machine must have NixOS already installed

3. **Network Configuration**
   - Update `universe.deployment.hostname` in your system configuration
   - Ensure target machine has internet access

## Quick Start

### Using the Deployment Script
```bash
./scripts/deploy.sh deploy quasar  # Deploy to quasar node
./scripts/deploy.sh deploy         # Deploy to all nodes
```

### Manual Commands
```bash
# Deploy configuration
deploy .#quasar
```

## Disk Management with Disko

The `disko` module allows you to define and manage disk layouts as part of your NixOS configuration. When deployed, it will automatically format disks according to your configuration.

### Disk Configuration

The disk configuration is defined in `systems/x86_64-linux/quasar/disks.nix`:
- **ZFS Pool**: 4x 10TB drives in striped mirror (18.2TB usable)
- **NVMe System**: 2TB BTRFS for NixOS root
- **Mountpoint**: `/mnt/media` for media storage

⚠️ **WARNING**: Deploying this configuration will format the specified disks!

## Configuration Deployment with deploy-rs

### 1. Update System Configuration

Edit `systems/x86_64-linux/quasar/default.nix` and update the hostname:
```nix
universe.deployment = {
  enable = true;
  hostname = "your-actual-hostname-or-ip";
  # ... rest of configuration
};
```

### 2. Deploy System Configuration

```bash
# Deploy system-level changes (requires root SSH access)
deploy .#quasar.system

# Deploy everything
deploy .#quasar

# Or use the deployment script
./scripts/deploy.sh deploy quasar
```

### 3. Verify Deployment

```bash
# Check system status on target
ssh root@your-hostname 'systemctl status'

# Check services
ssh root@your-hostname 'systemctl status jellyfin'
ssh root@your-hostname 'systemctl status nginx'
```

## Configuration Structure

### System Configuration
- **Main Config**: `systems/x86_64-linux/quasar/default.nix`
- **Disk Layout**: `systems/x86_64-linux/quasar/disks.nix`
- **Hardware**: `systems/x86_64-linux/quasar/hardware-configuration.nix`

### Deploy Configuration
- **Deploy Nodes**: Defined in `flake.nix`
- **Profiles**: System configurations
- **SSH Users**: root (system), dylan (user)

## Troubleshooting

### deploy-rs Issues

**Deploy Failed:**
```bash
# Check flake validity
nix flake check

# Test configuration build
nix build .#nixosConfigurations.quasar.config.system.build.toplevel

# Debug deploy with verbose output
deploy .#quasar --debug-logs
```

**SSH Authentication:**
- Verify SSH key access to target
- Check SSH agent: `ssh-add -l`
- Test manual SSH: `ssh root@hostname`

**Profile Activation Failed:**
- Check system compatibility
- Verify all required secrets are accessible
- Review target system logs: `journalctl -xeu`

## Security Considerations

### Secrets Management
- Secrets are managed with SOPS-nix
- Age keys required for decryption: `/etc/sops/age/system.txt`
- User secrets deployed to appropriate paths

### SSH Security
- Key-based authentication enforced
- Root login restricted to deployment only
- Consider disabling password auth post-installation

### Network Security
- Firewall configured per service requirements
- Nginx reverse proxy for web services
- VPN confinement for torrent services

## Maintenance

### Regular Updates
```bash
# Update flake inputs
nix flake update

# Deploy updates
deploy .#quasar

# Or use script
./scripts/deploy.sh deploy quasar
```

### Configuration Changes
1. Edit configuration files
2. Test locally: `nix build .#nixosConfigurations.quasar.config.system.build.toplevel`
3. Deploy: `deploy .#quasar`

### Rollbacks
```bash
# List generations on target
ssh root@hostname 'nixos-rebuild list-generations'

# Rollback to previous generation
ssh root@hostname 'nixos-rebuild switch --rollback'
```

## Advanced Usage

### Multiple Systems
Add additional systems to your flake by creating new system directories:
```
systems/
├── x86_64-linux/
│   ├── quasar/
│   │   ├── default.nix
│   │   └── disks.nix
│   └── nebula/
│       ├── default.nix
│       └── disks.nix
```

Configure deployment for each system:
```nix
# In systems/x86_64-linux/nebula/default.nix
universe.deployment = {
  enable = true;
  hostname = "nebula.local";
  fastConnection = true;
  sshUser = "root";
  user = "root";
};
```

### Development Workflow
```bash
# Enter development environment
nix develop

# Make changes to configuration
# ... edit files ...

# Test configuration
nix flake check

# Build configuration
./scripts/deploy.sh build quasar

# Deploy when ready
./scripts/deploy.sh deploy quasar
```

## References

- [deploy-rs Documentation](https://github.com/serokell/deploy-rs)
- [Snowfall Documentation](https://snowfall.org/reference/lib/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [SOPS-nix Documentation](https://github.com/Mic92/sops-nix)