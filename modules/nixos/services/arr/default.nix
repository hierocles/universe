{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.arr = with types; {
    enable = mkBoolOpt false "Whether or not to enable *arr services base configuration.";

    user = mkOption {
      type = str;
      default = "arr";
      description = "User to run *arr services as.";
    };

    group = mkOption {
      type = str;
      default = "arr";
      description = "Group for *arr services.";
    };

    mediaPath = mkOption {
      type = str;
      default = "/mnt/media";
      description = "Base path for media storage.";
    };

    downloadPath = mkOption {
      type = str;
      default = "/mnt/media/downloads";
      description = "Path for downloads.";
    };

    tvPath = mkOption {
      type = str;
      default = "/mnt/media/tv";
      description = "Path for TV shows.";
    };

    moviesPath = mkOption {
      type = str;
      default = "/mnt/media/movies";
      description = "Path for movies.";
    };

    musicPath = mkOption {
      type = str;
      default = "/mnt/media/music";
      description = "Path for music.";
    };

    booksPath = mkOption {
      type = str;
      default = "/mnt/media/books";
      description = "Path for books.";
    };

    configPath = mkOption {
      type = str;
      default = "/var/lib/arr";
      description = "Base path for *arr configuration.";
    };
  };

  config = mkIf cfg.enable {
    # Create user and group for *arr services
    users.groups.${cfg.group} = {};
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.configPath;
      createHome = true;
    };

    # Ensure media directories exist with correct permissions (only for enabled services)
    systemd.tmpfiles.rules = lib.flatten [
      # Always create base directories when arr is enabled
      [
        "d ${cfg.mediaPath} 0755 ${cfg.user} ${cfg.group} -"
        "d ${cfg.configPath} 0755 ${cfg.user} ${cfg.group} -"
      ]
      # Create directories only for enabled services
      (lib.optionals config.${namespace}.services.torrent.enable [
        "d ${cfg.downloadPath} 0755 ${cfg.user} ${cfg.group} -"
      ])
      (lib.optionals config.${namespace}.services.sonarr.enable [
        "d ${cfg.tvPath} 0755 ${cfg.user} ${cfg.group} -"
      ])
      (lib.optionals config.${namespace}.services.radarr.enable [
        "d ${cfg.moviesPath} 0755 ${cfg.user} ${cfg.group} -"
      ])
      # Future implementations
      # (lib.optionals config.${namespace}.services.lidarr.enable [
      #   "d ${cfg.musicPath} 0755 ${cfg.user} ${cfg.group} -"
      # ])
      # (lib.optionals config.${namespace}.services.readarr.enable [
      #   "d ${cfg.booksPath} 0755 ${cfg.user} ${cfg.group} -"
      # ])
    ];

    # Open firewall ports only for enabled services
    networking.firewall.allowedTCPPorts = lib.flatten [
      # Only open ports for services that are actually enabled
      (lib.optionals config.${namespace}.services.sonarr.enable [8989]) # Sonarr
      (lib.optionals config.${namespace}.services.radarr.enable [7878]) # Radarr
      (lib.optionals config.${namespace}.services.prowlarr.enable [9696]) # Prowlarr
      (lib.optionals config.${namespace}.services.bazarr.enable [6767]) # Bazarr
      (lib.optionals config.${namespace}.services.jellyseerr.enable [5055]) # Jellyseerr
      (lib.optionals config.${namespace}.services.plex.enable [32400]) # Plex
      (lib.optionals config.${namespace}.services.jellyfin.enable [8096]) # Jellyfin
      (lib.optionals config.${namespace}.services.torrent.enable [9091]) # Transmission
      # Note: Lidarr and Readarr ports kept for future implementation
      # (lib.optionals config.${namespace}.services.lidarr.enable [ 8686 ])    # Lidarr
      # (lib.optionals config.${namespace}.services.readarr.enable [ 8787 ])   # Readarr
    ];

    networking.firewall.allowedUDPPorts = lib.flatten [
      # Only open UDP ports for services that need them
      (lib.optionals config.${namespace}.services.torrent.enable [51413]) # Transmission peer port
    ];
  };
}
