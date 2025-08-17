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
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    # Configure Transmission service
    services.transmission = {
      enable = true;
      inherit (cfg) user group openFirewall;

      home = "${arrCfg.configPath}/transmission";

      settings = mkMerge [
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
          "rpc-authentication-required" = false; # Can be enabled via extraSettings
        }
        cfg.extraSettings
      ];
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
