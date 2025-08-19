{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    user = {
      name = "dylan";
    };
    nix = {
      enable = true;
      extra-substituters = {
        "https://nix-community.cachix.org" = {
          key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        };
        "https://numtide.cachix.org" = {
          key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
        };
      };
    };
    suites = {
      common = enabled;
    };
    system = {
      wsl = {
        enable = true;
        default-user = config.${namespace}.user.name;
      };
    };

    tools = {
      nil = enabled;
      cursor-server = enabled;
    };
    security = {
      gpg = enabled;
      sops = {
        enable = true;
        defaultSopsFile = ../../../secrets/secrets.yaml;
        ageKeyFile = "/etc/sops/age/system.txt";
        userSecrets = {
          dylan = {
            "ssh-public-key" = {
              mode = "0644";
              path = "/home/dylan/.ssh/id_andromeda.pub";
            };
            "ssh-private-key" = {
              mode = "0600";
              path = "/home/dylan/.ssh/id_andromeda";
            };
            "pgp-public-key-fingerprint" = {
              mode = "0644";
              path = "/home/dylan/.gnupg/public-key-fingerprint.txt";
            };
          };
        };
      };
    };
  };

  system.stateVersion = "25.05";
}
