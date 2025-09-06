# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a NixOS configuration repository using **Snowfall Lib** (https://snowfall.org/) for opinionated structure and organization. The configuration manages both NixOS systems and Home Manager user environments with the namespace `universe`.

### Core Framework: Snowfall Lib

- **Namespace**: `universe` (defined in flake.nix)
- **Module Discovery**: Automatic discovery of modules in `/modules` folder via git (modules must be staged with `git add`)
- **Opinionated Structure**: Follows Snowfall lib conventions for organizing NixOS modules, home-manager modules, packages, overlays, and shells
- **Deployment**: Uses deploy-rs for remote system deployment with built-in rollback capability

### Directory Structure

```
/modules/
  /nixos/          # NixOS system modules (automatic discovery)
  /home/           # Home Manager modules (automatic discovery)
/packages/         # Custom packages
/overlays/         # Package overlays
/shells/           # Development shells
/systems/          # System configurations
/homes/            # Home configurations
/lib/              # Custom library functions
/secrets/          # SOPS encrypted secrets (secrets.yaml)
```

### Module Organization Patterns

- **Archetypes**: High-level configuration patterns (e.g., `modules/nixos/archetypes/server`, `modules/home/archetypes/headless`)
- **Suites**: Collections of related modules (e.g., `modules/nixos/suites/common`)
- **Service Modules**: Individual service configurations in `modules/nixos/services/`
- **Tools**: Development and utility tools in `modules/nixos/tools/` and `modules/home/tools/`

## Common Development Commands

### Primary Commands
```bash
# Validate entire configuration
just check
# Equivalent to: nix flake check --impure

# Stage modules for discovery (REQUIRED)
git add modules/path/to/new-module/

# Deploy to remote system
nix run github:serokell/deploy-rs -- .#hostname

# Build system configuration locally
nix build .#nixosConfigurations.hostname.config.system.build.toplevel
```

### Code Quality Commands
```bash
# Format Nix code (alejandra)
nix run nixpkgs#alejandra -- .

# Remove unused code (deadnix)
nix run nixpkgs#deadnix -- .

# Check best practices (statix)
nix run nixpkgs#statix -- .
```

### Development Shells
```bash
# Enter default development shell
nix develop

# Enter deployment shell
nix develop .#deploy-shell
```

## Configuration Patterns

### Module Structure Template
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

### Common Snowfall Lib Patterns
```nix
# Enable modules using the 'enabled' helper
universe.services.openssh = enabled;

# Reference other config values
inherit (cfg) hostId;

# SOPS secrets usage
sops.secrets."secret-name".path = "/path/to/decrypted/secret";
```

### System Configuration Example
```nix
# systems/x86_64-linux/hostname/default.nix
{
  lib,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    user.name = "username";
    suites.common = enabled;
    system.boot = {
      enable = true;
      efi = true;
    };
  };
}
```

## Secrets Management (SOPS)

### SOPS Configuration
- Encrypted secrets stored in `/secrets/secrets.yaml`
- Uses age encryption with SSH keys
- Secrets decrypted at build/deploy time

### SOPS Usage Patterns
```nix
# Define secrets
sops = {
  enable = true;
  defaultSopsFile = ../../../secrets/secrets.yaml;
  secrets = {
    "secret-name" = {
      mode = "0644";
      path = "/var/lib/secrets/secret-file";
    };
  };
};

# Reference decrypted secret
someService.credentialsFile = config.sops.secrets."secret-name".path;
```

## Deployment Configuration

### Deploy-rs Setup
```nix
deploy = lib.mkDeploy {
  inherit (inputs) self;
  overrides = {
    hostname = {
      hostname = "192.168.1.100";
      user = "username";
      sshUser = "username";
      profiles.system = {
        fastConnection = true;
      };
      sshOpts = ["-o" "ForwardX11=no"];
    };
  };
};
```

### Deployment Commands
```bash
# Deploy system configuration
nix run github:serokell/deploy-rs -- .#hostname

# Rollback deployment
nix run github:serokell/deploy-rs -- .#hostname --rollback
```

## Quality Assurance

### Pre-commit Hooks
Automatically runs on commits:
- **Alejandra**: Code formatting
- **Deadnix**: Dead code removal
- **Statix**: Best practices enforcement

### Development Workflow
1. Create/modify modules in appropriate directories
2. Stage modules with `git add` (required for discovery)
3. Test locally: `just check`
4. Fix any linting/validation errors
5. Commit changes with descriptive messages

## Key Inputs and Dependencies

- **nixpkgs**: Main package repository
- **home-manager**: User environment management
- **deploy-rs**: Remote deployment system
- **sops-nix**: Secrets management
- **nixos-wsl**: WSL support
- **disko**: Disk partitioning
- **nixarr**: Media server automation
- **nixvim**: Neovim configuration

## Important Notes

- **Module Discovery**: Modules must be staged (`git add`) to be discovered by Snowfall lib
- **Namespace**: All custom options use the `universe` namespace
- **Secrets**: Never commit unencrypted secrets; use SOPS for all sensitive data
- **Testing**: Always run `just check` before committing to validate configuration
- **Deployment**: Use deploy-rs for remote deployments with proper SSH configuration