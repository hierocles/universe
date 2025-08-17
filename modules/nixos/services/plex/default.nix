{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.plex;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.plex = with types; {
    enable = mkBoolOpt false "Whether or not to enable Plex Media Server.";

    port = mkOption {
      type = port;
      default = 32400;
      description = "Port for Plex web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Plex.";

    dataDir = mkOption {
      type = str;
      default = "${arrCfg.configPath}/plex";
      description = "Directory where Plex stores its data files.";
    };

    user = mkOption {
      type = str;
      default = arrCfg.user;
      description = "User account under which Plex runs.";
    };

    group = mkOption {
      type = str;
      default = arrCfg.group;
      description = "Group under which Plex runs.";
    };

    accelerationDevices = mkOption {
      type = listOf str;
      default = [];
      example = ["/dev/dri/renderD128"];
      description = "Hardware acceleration devices for transcoding.";
    };

    extraPlugins = mkOption {
      type = listOf path;
      default = [];
      description = "Extra plugin bundles to install.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.plex = {
      enable = true;
      inherit (cfg) dataDir user group openFirewall accelerationDevices extraPlugins;
    };

    # Create plex-specific config directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    # Ensure the plex user has access to media directories
    systemd.services.plex = {
      serviceConfig = {
        SupplementaryGroups = [cfg.group];
      };
    };
  };
}
