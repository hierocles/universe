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

    # Snowfall Flake
    #flake.url = "github:snowfallorg/flake";
    #flake.inputs.nixpkgs.follows = "nixpkgs";

    # Snowfall Thaw
    #thaw.url = "github:snowfallorg/thaw";

    # Snowfall Drift
    #drift.url = "github:snowfallorg/drift";
    #drift.inputs.nixpkgs.follows = "nixpkgs";

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

    # Hardware
    nixos-hardware.url = "github:nixos/nixos-hardware";

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
  in
    lib.mkFlake
    {
      channels-config = {
        allowUnfree = true;
      };

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
      ];

      systems.hosts.andromeda.modules = with inputs; [
        nixos-wsl.nixosModules.wsl
        cursor-server.nixosModules.default
      ];

      outputs-builder = channels: {formatter = channels.nixpkgs.alejandra;};
    };
}
