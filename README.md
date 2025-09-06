# 🌌 Universe

A NixOS configuration using [Snowfall Lib](https://snowfall.org/) for structured and scalable system management.

## 🏗️ Architecture

This configuration uses **Snowfall Lib** with the `universe` namespace to provide:

- **Modular Structure**: Automatic discovery of NixOS and Home Manager modules
- **Multi-System Support**: Configurations for multiple machines and architectures
- **Secrets Management**: SOPS-encrypted secrets with age encryption
- **Remote Deployment**: Deploy-rs integration for system deployment and rollback

## 📁 Directory Structure

```
├── modules/
│   ├── nixos/          # NixOS system modules
│   └── home/           # Home Manager modules
├── systems/            # System configurations
├── homes/              # Home Manager configurations
├── packages/           # Custom packages
├── overlays/           # Package overlays
├── shells/             # Development shells
├── lib/                # Custom library functions
├── secrets/            # SOPS encrypted secrets
└── checks/             # Configuration validation
```

## 🚀 Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)

### Development Environment

```bash
# Enter development shell
nix develop

# Or with just
just dev

# Validate configuration
just check

# Format code
just format

# Run all quality checks
just quality
```

### Building Systems

```bash
# Build a system configuration
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Example: Build quasar system
just build-quasar
```

### Deployment

```bash
# Deploy to remote system
just deploy-<hostname>

# Example: Deploy to quasar
just deploy-quasar

# Rollback if needed
just rollback-<hostname>
```

## 🔧 Configuration Management

### Adding New Modules

1. Create module in appropriate directory:
   ```bash
   # NixOS module
   mkdir -p modules/nixos/services/myservice
   
   # Home Manager module  
   mkdir -p modules/home/tools/mytool
   ```

2. Stage modules for discovery:
   ```bash
   git add modules/nixos/services/myservice/
   ```

3. Use in system configuration:
   ```nix
   universe.services.myservice = enabled;
   ```

### Module Structure

```nix
{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.category.module-name;
in {
  options.universe.category.module-name = with types; {
    enable = mkBoolOpt false "Whether to enable this module.";
  };

  config = mkIf cfg.enable {
    # Implementation
  };
}
```

### Secrets Management

Secrets are managed using SOPS with age encryption:

```bash
# Edit secrets
sops secrets/secrets.yaml

# Use in modules
sops.secrets."secret-name" = {
  mode = "0644";
  path = "/var/lib/secrets/secret-file";
};
```

## 🏢 System Configurations

Current systems managed by this configuration:

- **andromeda**: NixOS on WSL
- **quasar**: Media server
- **installer**: ISO installation media

Systems are organized by architecture in `systems/<arch>/<hostname>/`.

## 🏠 Home Manager

User environments are configured using Home Manager with the same modular approach:

```nix
# homes/<architecture>/<user>@<hostname>/default.nix
# or homes/<architecture>/<user>/default.nix to apply the same home config to all hosts
{
  universe = {
    user.name = "username";
    suites.common = enabled;
    tools.git = enabled;
  };
}
```

## 📦 Packages & Overlays

Custom packages and modifications are organized in:

- `packages/`: Custom derivations
- `overlays/`: Package modifications and additions

## 🧪 Development Shells

Multiple development environments available:

```bash
# Default shell
nix develop

# Deployment shell with deploy-rs
nix develop .#deploy-shell
```

## ⚡ Common Tasks

```bash
# Validate entire configuration
just check

# Format all Nix code  
just format

# Remove unused code
just clean

# Check best practices
just lint

# Run all quality checks
just quality

# Update flake inputs
just update

# Show available outputs
just show

# Local rebuild (on NixOS)
just rebuild
```

## 🔍 Quality Assurance

Pre-commit hooks automatically enforce:

- **Alejandra**: Code formatting
- **Deadnix**: Dead code removal  
- **Statix**: Best practices enforcement

## 📚 Key Dependencies

- **nixpkgs**: Main package repository
- **snowfall-lib**: Configuration structure and utilities
- **home-manager**: User environment management
- **deploy-rs**: Remote deployment system
- **sops-nix**: Secrets management
- **nixos-wsl**: WSL support
- **nixos-generators**: System image generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Stage modules: `git add modules/path/to/module/`
4. Test changes: `just check`
5. Commit with descriptive messages
6. Submit pull request

---

*Built with ❄️ [Nix](https://nixos.org) and 📦 [Snowfall Lib](https://snowfall.org/)*