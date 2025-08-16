{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    nix = {
      enabled = true;
      extra-substituters = {
        nix-community = {
          url = "https://nix-community.cachix.org";
          key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        };
        numtide = {
          url = "https://numtide.cachix.org";
          key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
        };
      };
    };
    system = {
      wsl = {
        enable = true;
        default-user = config.${namespace}.user.name;
      };
    };
    cli-apps = {
      neovim = enabled;
    };
    tools = {
      git = enabled;
      comma = enabled;
      nix-ld = enabled; # Required for cursor-server
      nil = enabled;
      cursor-server = enabled;
    };
  };

  system.stateVersion = "25.05";
}
