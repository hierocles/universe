{
  lib,
  namespace,
  config,
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

    suites = {
      common = enabled;
    };

    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zfs = {
        enable = true;
        hostId = "01749328"; # Required for ZFS
      };
    };

    tools = {
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
      jellyseerr = enabled; # Request management

      # Media servers (choose one or both)
      plex = enabled; # Commercial media server with premium features
      jellyfin = disabled; # Open source media server

      # VPN and Torrenting (configure wireguardConfigFile path)
      vpn = {
        enable = true;
        namespaceName = "torrent";
        wireguardConfigFile = config.sops.secrets.wg-conf.path;
        accessibleFrom = ["192.168.0.0/16" "10.0.0.0/8"];
        portMappings = [
          {
            from = 9091; # Transmission RPC port
            to = 9091;
            protocol = "tcp";
          }
        ];
        openVPNPorts = [
          {
            port = 51413; # Transmission peer port
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
        peerPort = 51413; # Transmission peer port
        authentication = {
          enable = true;
          credentialsFile = config.sops.secrets."transmission-rpc-credentials".path;
        };
      };

      # Nginx reverse proxy for easy access
      nginx = {
        enable = true;
        domain = "quasar.local";
        ssl = true;
        acme = true;
        openFirewall = true;
      };
    };

    security = {
      gpg = enabled;
      sops = {
        enable = true;
        defaultSopsFile = ../../../secrets/secrets.yaml;
        ageKeyFile = "/etc/sops/age/system.txt";

        secrets = {
          "transmission-rpc-credentials" = {
            owner = "arr";
            group = "arr";
            mode = "0600";
          };
          "wg-conf" = {
            mode = "0600";
            path = "/etc/wireguard/wg0.conf";
          };
        };

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
