{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Snowfall
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cursor Server for remote development
    cursor-server = {
      url = "github:zoid-archive/nixos-cursor-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # MacOS
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # GPG
    gpg-base-conf = {
      url = "github:drduh/config";
      flake = false;
    };

    # Comma
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";

    # Run unpatched dynamically compiled binaries
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # System Deployment
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    # SOPS for secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Pre-commit hooks
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # Disko for disk configuration
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # VPN Confinement for secure torrenting
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    # Secrets repo
    secrets-repo = {
      url = "git+ssh://git@github.com/hierocles/snowfall-secrets?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "universe";
        meta = {
          name = "universe";
          title = "Universe";
        };
      };
    };

    # Create the flake first so we can reference it
    flake = lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        nixos-wsl.nixosModules.wsl
        cursor-server.nixosModules.default
        vpn-confinement.nixosModules.default
      ];

      # Define system specialArgs
      systems.specialArgs = {
        # Pass the disko module to system configurations
        inherit (inputs) disko;
      };

      outputs-builder = channels: let
        system = channels.nixpkgs.system;
      in {
        inherit (channels.nixpkgs) alejandra;

        checks = {
          inherit (channels.nixpkgs) deadnix statix;
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              deadnix.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs; [
            git
            sops
            age
          ];

          shellHook = ''
            echo "🚀 NixOS Development Environment"
            echo "Available tools:"
            echo "  • sops       - Edit secrets"
          '';
        };

        devShells.deploy = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs; [
            git
            inputs.deploy-rs.packages.${system}.default
            sops
            age
          ];

          shellHook = ''
            echo "🚀 NixOS Deployment Environment"
            echo "Available tools:"
            echo "  • deploy     - Deploy configurations with deploy-rs"
            echo "  • sops       - Edit secrets"
            echo "  • nixos-rebuild - Test configurations locally"
            echo ""
            echo "Usage examples:"
            echo "  deploy .#quasar           - Deploy to quasar system"
          '';
        };
      };
    };

    # Define deploy-rs configuration using the flake we just created
    deployConfig = {
      nodes = {
        quasar = {
          hostname = "192.168.8.115"; # Updated with your actual IP
          fastConnection = true;
          profiles.system = {
            sshUser = "dylan"; # Updated to use your user account
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos flake.nixosConfigurations.quasar;
            user = "root"; # This is still root for system activation
          };
        };
      };
    };
  in
    flake
    // {
      # Add deploy-rs configuration outside of Snowfall structure
      deploy = deployConfig;

      # Add deploy-rs checks
      checks.x86_64-linux = inputs.deploy-rs.lib.x86_64-linux.deployChecks deployConfig;
    };
}
