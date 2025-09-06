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

  networking = {
    hostName = "quasar";
    enableIPv6 = false;
    interfaces = {
      enp3s0 = {
        ipv4.addresses = [
          {
            address = "192.168.8.115";
            prefixLength = 24;
          }
        ];
      };
    };
    #firewall = {
    #  enable = true;
    #  allowedTCPPorts = [
    #    80
    #    443
    #  ];
    #};
    defaultGateway = {
      address = "192.168.8.1";
      interface = "enp3s0";
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

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
      # nixarr = enabled;
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

    security = {
      gpg = enabled;
      doas = enabled;
      sops = {
        enable = true;
        defaultSopsFile = ../../../secrets/secrets.yaml;
        ageSshKeyPaths = [
          "/etc/ssh/ssh_host_ed25519_key"
        ];
        generateKey = true;

        secrets = {
          "transmission-rpc-credentials" = {
            mode = "0644";
            path = "/var/lib/secrets/transmission/rpc-credentials.json";
          };
          "wg-conf" = {
            mode = "0644";
            path = "/var/lib/secrets/wireguard/wg0.conf";
          };
          "wg-conf-ipv4-only" = {
            mode = "0644";
            path = "/var/lib/secrets/wireguard/wg0-ipv4-only.conf";
          };
          "njalla-keys" = {
            mode = "0644";
            path = "/var/lib/secrets/njalla/keys.json";
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

  # TODO: Move to a module
  nixarr = {
    enable = true;
    mediaDir = "/mnt/media";
    stateDir = "/var/lib/nixarr/state";
    vpn = {
      enable = true;
      accessibleFrom = [
        "192.168.8.0/24"
      ];
      wgConf = config.sops.secrets."wg-conf-ipv4-only".path; # TODO: Make into a module parameter
      vpnTestService = {
        enable = true;
        port = 28813;
      };
    };

    ddns.njalla = {
      enable = true;
      keysFile = config.sops.secrets."njalla-keys".path;
    };

    autosync = true;
    transmission = {
      enable = true;
      peerPort = 28813;
      #credentialsFile = config.sops.secrets."transmission-rpc-credentials".path; # TODO: Make into a module parameter
      flood.enable = true;
      vpn.enable = true;
      privateTrackers = {
        cross-seed = {
          enable = true;
          indexIds = [
            8
            9
            10
          ];
          extraSettings = {
            rssCadence = "30 minutes";
            searchCadence = "1 day";
            excludeOlder = "2 weeks";
            excludeRecentSearch = "3 days";
          };
        };
      };
    };

    autobrr.enable = true;
    bazarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
    plex = {
      enable = true;
      # Build fails on attempting ACME challenge and I can't figure out why
      #  expose.https = {
      #    enable = true;
      #    domainName = "watch.hierocles.win";
      #    acmeMail = "acme@hierocles.win";
      #  };
    };
    jellyseerr = {
      enable = true;
      #  expose.https = {
      #    enable = true;
      #    domainName = "requests.hierocles.win";
      #    acmeMail = "acme@hierocles.win";
      #  };
    };

    recyclarr = {
      enable = true;
      configFile = ./recyclarr.yaml;
    };
  };

  # TODO: Flaresolverr module or include in nixarr module?
  services.flaresolverr = {
    enable = true;
  };
  system.stateVersion = "25.05";
}
