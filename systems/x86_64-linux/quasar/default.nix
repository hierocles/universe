{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

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

    system = {
      boot = {
        enable = true;
        loader = "systemd-boot";
        efi = true;
      };
      networking = {
        enable = true;
        hostId = "8425e349"; # Required for ZFS
      };
    };

    tools = {
      git = enabled;
      comma = enabled;
      nix-ld = enabled; # Required for cursor-server
      nil = enabled;
      cursor-server = enabled;
    };
    # TODO: Write *arr modules
    # TODO: Write VPN module

    security = {
      gpg = enabled;
      sops = {
        enable = true;
        defaultSopsFile = ../../../secrets/sops.yaml;
        ageKeyFile = "/etc/sops/age/system.txt";
        userSecrets = {
          dylan = {
            "gpg-public-key" = {
              mode = "0644";
              path = "/home/dylan/.gnupg/dylan-gpg-public.asc";
            };
          };
        };
      };
    };
  };

  system.stateVersion = "25.05";
}
