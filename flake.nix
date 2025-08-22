{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Snowfall
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Flake
    snowfall-flake.url = "github:snowfallorg/flake";
    snowfall-flake.inputs.nixpkgs.follows = "nixpkgs";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

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

    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";

    kickstart-nix.url = "github:nix-community/kickstart-nix.nvim";
    kickstart-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Use this fork of nixarr until the main repo is updated
    nixarr.url = "git+https://github.com/cramt/nixarr.git?ref=add_autosync";

    # Secret repo, contains secrets that don't need to be encrypted
    variables = {
      url = "git+ssh://git@github.com/hierocles/snowfall-secrets?ref=main&shallow=1";
      flake = true;
    };
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
        snowfall-flake.overlays."package/flake"
        kickstart-nix.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nix-ld.nixosModules.nix-ld
        nix-topology.nixosModules.default
        sops-nix.nixosModules.sops
        cursor-server.nixosModules.default
        nixos-wsl.nixosModules.wsl
        disko.nixosModules.disko
        nixarr.nixosModules.default
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
        hooks.pre-commit-check = inputs.pre-commit-hooks.lib.${channels.nixpkgs.system}.run {
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
