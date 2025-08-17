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

    services = {
      # *arr stack for media management
      arr = {
        enable = true;
        mediaPath = "/mnt/media";
        user = "arr";
        group = "arr";
      };
      # *arr services for media management
      sonarr = enabled; # TV show management
      radarr = enabled; # Movie management
      prowlarr = enabled; # Indexer management
      bazarr = enabled; # Subtitle management
      jellyseerr = enabled; # Request management (Jellyfin-focused)

      # Media servers (choose one or both)
      plex = disabled; # Commercial media server with premium features
      jellyfin = enabled; # Open source media server

      # VPN and Torrenting (configure wireguardConfigFile path)
      vpn = {
        enable = true;
        namespaceName = "torrent";
        wireguardConfigFile = "/etc/wireguard/wg0.conf"; # Update this path
        accessibleFrom = ["192.168.0.0/16" "10.0.0.0/8"];
        portMappings = [
          {
            from = 9091;
            to = 9091;
            protocol = "tcp";
          }
        ];
        openVPNPorts = [
          {
            port = 51413;
            protocol = "both";
          }
        ];
      };

      torrent = {
        enable = true;
        useVPN = true;
        downloadDir = "/mnt/media/downloads/completed";
        incompleteDir = "/mnt/media/downloads/incomplete";
        watchDir = "/mnt/media/downloads/watch";
        extraSettings = {
          # Optional: Enable authentication
          # "rpc-authentication-required" = true;
          # "rpc-username" = "transmission";
          # "rpc-password" = "your-password-here";
        };
      };

      # Nginx reverse proxy for easy access
      nginx = {
        enable = true;
        domain = "quasar.local";
        ssl = false; # Set to true and enable acme for production
        acme = false;
        openFirewall = true;
      };
    };

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
