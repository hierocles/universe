{
  inputs = {
    # nixpkgs-unstable
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Snowfall
    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    # Snowfall Flake
    snowfall-flake.url = "github:snowfallorg/flake";
    snowfall-flake.inputs.nixpkgs.follows = "nixpkgs";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Cursor Server for remote development
    cursor-server.url = "github:zoid-archive/nixos-cursor-server";
    cursor-server.inputs.nixpkgs.follows = "nixpkgs";

    # VS Code server
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # MacOS
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # GPG
    gpg-base-conf.url = "github:drduh/config";
    gpg-base-conf.flake = false;

    # Comma
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";

    # Run unpatched dynamically compiled binaries
    #nix-ld.url = "github:Mic92/nix-ld";
    #nix-ld.inputs.nixpkgs.follows = "nixpkgs";

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

    # Use this fork of nixarr until the main repo is updated
    nixarr.url = "git+https://github.com/hierocles/nixarr.git?ref=test-prs-78-80";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = inputs: let
    inherit (inputs) deploy-rs;
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
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      overlays = with inputs; [
        snowfall-flake.overlays.default
        claude-code.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        cursor-server.nixosModules.default
        vscode-server.nixosModules.default
        nixos-wsl.nixosModules.wsl
        disko.nixosModules.disko
        nixarr.nixosModules.default
        #nix-ld.nixosModules.default
      ];

      systems.modules.darwin = with inputs; [
        nix-homebrew.darwinModules.default
        home-manager.darwinModules.home-manager
      ];

      homes.modules = with inputs; [
        nixvim.homeModules.nixvim
      ];

      deploy = lib.mkDeploy {
        inherit (inputs) self;
        overrides = {
          quasar = {
            hostname = "192.168.8.115";
            user = "dylan";
            sshUser = "dylan";
            profiles.system = {
              fastConnection = true;
            };
            sshOpts = ["-o" "ForwardX11=no"];
          };
        };
      };

      checks =
        builtins.mapAttrs
        (_system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy)
        deploy-rs.lib;

      outputs-builder = channels: {
        hooks.pre-commit-check = inputs.pre-commit-hooks.lib.${channels.nixpkgs.stdenv.hostPlatform.system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        };
      };
    };
}
