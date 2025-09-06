{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.suites.common;
in {
  options.universe.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    universe = {
      nix = {
        enable = true;
        extra-substituters = {
          # Core NixOS cache
          "https://cache.nixos.org" = {
            key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
          };

          # Nix community cache
          "https://nix-community.cachix.org" = {
            key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
          };

          # Numtide cache
          "https://numtide.cachix.org" = {
            key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
          };
        };
      };

      cli-apps = {
        flake = enabled;
      };

      tools = {
        git = enabled;
        misc = enabled;
        nix-output-monitor = enabled;
        comma = enabled;
      };

      # hardware = {
      #   networking = enabled;
      # };

      services = {
        openssh = {
          enable = true;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIt0bjd1TRJ18rMizFAQVz5MU5oDIagcLw0cfio4zaZd dylan@andromeda"
          ];
        };
      };

      system = {
        locale = enabled;
        time = enabled;
        zsh = enabled;
      };
    };
  };
}
