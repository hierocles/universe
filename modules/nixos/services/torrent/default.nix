{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.torrent;
  arrCfg = config.${namespace}.services.arr;
  vpnCfg = config.${namespace}.services.vpn;
in {
  options.${namespace}.services.torrent = with types; {
    enable = mkBoolOpt false "Whether or not to enable torrent client (Transmission).";

    client = mkOption {
      type = enum ["transmission"];
      default = "transmission";
      description = "Which torrent client to use.";
    };

    port = mkOption {
      type = port;
      default = 9091;
      description = "Port for torrent client web interface.";
    };

    peerPort = mkOption {
      type = port;
      default = 51413;
      description = "Port for torrent peer connections.";
    };

    downloadDir = mkOption {
      type = str;
      default = "${arrCfg.downloadPath}";
      description = "Directory where completed torrents are stored.";
    };

    incompleteDir = mkOption {
      type = str;
      default = "${arrCfg.downloadPath}/incomplete";
      description = "Directory for incomplete torrents.";
    };

    watchDir = mkOption {
      type = str;
      default = "${arrCfg.downloadPath}/watch";
      description = "Directory to watch for .torrent files.";
    };

    user = mkOption {
      type = str;
      default = arrCfg.user;
      description = "User account under which torrent client runs.";
    };

    group = mkOption {
      type = str;
      default = arrCfg.group;
      description = "Group under which torrent client runs.";
    };

    useVPN = mkBoolOpt true "Whether to confine torrent client to VPN namespace.";

    vpnNamespace = mkOption {
      type = str;
      default = vpnCfg.namespaceName;
      description = "VPN namespace to confine torrent client to.";
    };

    rpcWhitelist = mkOption {
      type = listOf str;
      default = ["127.0.0.1" "192.168.*.*" "10.*.*.*" "172.16.*.*"];
      description = "RPC whitelist for web interface access.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall ports.";

    extraSettings = mkOption {
      type = attrs;
      default = {};
      description = "Extra settings for the torrent client.";
    };

    # New options for authentication
    authentication = {
      enable = mkBoolOpt false "Whether to enable authentication for the torrent client.";

      usernameFile = mkOption {
        type = nullOr str;
        default = null;
        description = "Path to a file containing the username for authentication.";
        example = "/run/secrets/transmission-username";
      };

      passwordFile = mkOption {
        type = nullOr str;
        default = null;
        description = "Path to a file containing the password for authentication.";
        example = "/run/secrets/transmission-password";
      };

      username = mkOption {
        type = nullOr str;
        default = null;
        description = "Username for authentication (not recommended, use usernameFile instead).";
      };

      password = mkOption {
        type = nullOr str;
        default = null;
        description = "Password for authentication (not recommended, use passwordFile instead).";
      };
    };

    # Option for custom settings file
    settingsFile = mkOption {
      type = nullOr str;
      default = null;
      description = "Path to a custom settings file for the torrent client.";
      example = "/run/secrets/transmission-settings.json";
    };
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    # Configure Transmission service
    services.transmission = {
      enable = true;
      inherit (cfg) user group openFirewall;

      home = "${arrCfg.configPath}/transmission";

      # Use custom settings file if provided
      inherit (cfg) settingsFile;

      settings = mkIf (cfg.settingsFile == null) (mkMerge [
        {
          # Directory settings
          "download-dir" = cfg.downloadDir;
          "incomplete-dir" = cfg.incompleteDir;
          "incomplete-dir-enabled" = true;
          "watch-dir" = cfg.watchDir;
          "watch-dir-enabled" = true;

          # Network settings
          "peer-port" = cfg.peerPort;
          "rpc-port" = cfg.port;
          "rpc-bind-address" =
            if cfg.useVPN
            then "192.168.15.1"
            else "0.0.0.0";
          "rpc-whitelist" = concatStringsSep "," cfg.rpcWhitelist;
          "rpc-whitelist-enabled" = true;
          "rpc-host-whitelist-enabled" = false;

          # Performance settings
          "cache-size-mb" = 16;
          "dht-enabled" = true;
          "lpd-enabled" = true;
          "pex-enabled" = true;
          "utp-enabled" = true;

          # Speed limits (can be overridden in extraSettings)
          "speed-limit-down-enabled" = false;
          "speed-limit-up-enabled" = false;
          "ratio-limit-enabled" = false;

          # Privacy settings
          "encryption" = "preferred";
          "blocklist-enabled" = true;
          "blocklist-url" = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

          # Web interface settings
          "rpc-authentication-required" = cfg.authentication.enable;
        }
        (mkIf (cfg.authentication.enable && cfg.authentication.username != null) {
          "rpc-username" = cfg.authentication.username;
        })
        (mkIf (cfg.authentication.enable && cfg.authentication.password != null) {
          "rpc-password" = cfg.authentication.password;
        })
        cfg.extraSettings
      ]);
    };

    # Add a systemd service to apply authentication from files if needed
    systemd.services.transmission-auth =
      mkIf (
        cfg.authentication.enable
        && (cfg.authentication.usernameFile != null || cfg.authentication.passwordFile != null)
      ) {
        description = "Apply Transmission authentication settings from files";
        wantedBy = ["multi-user.target"];
        after = ["transmission.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          # Get the Transmission settings file
          SETTINGS_FILE="/var/lib/transmission/settings.json"

          # Wait for the settings file to be created by Transmission
          while [ ! -f "$SETTINGS_FILE" ]; do
            sleep 1
          done

          # Update the settings file with authentication settings
          ${optionalString (cfg.authentication.usernameFile != null) ''
            USERNAME=$(cat ${cfg.authentication.usernameFile})
            sed -i 's/"rpc-username": ".*"/"rpc-username": "'$USERNAME'"/' "$SETTINGS_FILE"
          ''}

          ${optionalString (cfg.authentication.passwordFile != null) ''
            PASSWORD=$(cat ${cfg.authentication.passwordFile})
            sed -i 's/"rpc-password": ".*"/"rpc-password": "'$PASSWORD'"/' "$SETTINGS_FILE"
          ''}

          # Restart Transmission to apply the settings
          systemctl restart transmission
        '';
      };

    # VPN Confinement for Transmission
    systemd.services.transmission.vpnConfinement = mkIf cfg.useVPN {
      enable = true;
      inherit (cfg) vpnNamespace;
    };

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d ${cfg.downloadDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.incompleteDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.watchDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${arrCfg.configPath}/transmission 0755 ${cfg.user} ${cfg.group} -"
    ];

    # Firewall rules for direct access (when not using nginx)
    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall && !cfg.useVPN) [cfg.port];
  };
}
