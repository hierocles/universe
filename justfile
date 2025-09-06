# Validate entire configuration
check:
  nix flake check --show-trace --log-format internal-json -v |& nom --json

# Format Nix code with alejandra
format:
  alejandra .

# Remove unused code with deadnix
clean:
  deadnix --edit

# Check Nix best practices with statix
lint:
  statix check

# Run all quality checks
quality: format clean lint check

# Deploy to quasar server
deploy-quasar:
  deploy-rs deploy .#quasar

# Rollback quasar deployment
rollback-quasar:
  deploy-rs rollback .#quasar

# Build system configuration locally
build-quasar:
  nix build .#nixosConfigurations.quasar.config.system.build.toplevel --log-format internal-json -v |& nom --json

# Update flake inputs
update:
  nix flake update

# Show flake outputs
show:
  nix flake show

# Enter development shell
dev:
  nix develop

# Enter deployment shell
dev-deploy:
  nix develop .#deploy-shell

rebuild:
  doas nixos-rebuild switch --flake . --log-format internal-json -v |& nom --json