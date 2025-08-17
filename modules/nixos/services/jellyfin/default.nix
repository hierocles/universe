{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.jellyfin;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.jellyfin = with types; {
    enable = mkBoolOpt false "Whether or not to enable Jellyfin Media Server.";

    port = mkOption {
      type = port;
      default = 8096;
      description = "Port for Jellyfin web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Jellyfin.";

    dataDir = mkOption {
      type = str;
      default = "${arrCfg.configPath}/jellyfin";
      description = "Base data directory for Jellyfin.";
    };

    configDir = mkOption {
      type = str;
      default = "${arrCfg.configPath}/jellyfin/config";
      description = "Directory containing server configuration files.";
    };

    cacheDir = mkOption {
      type = str;
      default = "${arrCfg.configPath}/jellyfin/cache";
      description = "Directory containing server cache.";
    };

    logDir = mkOption {
      type = str;
      default = "${arrCfg.configPath}/jellyfin/log";
      description = "Directory where Jellyfin logs will be stored.";
    };

    user = mkOption {
      type = str;
      default = arrCfg.user;
      description = "User account under which Jellyfin runs.";
    };

    group = mkOption {
      type = str;
      default = arrCfg.group;
      description = "Group under which Jellyfin runs.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.jellyfin = {
      enable = true;
      inherit (cfg) dataDir configDir cacheDir logDir user group openFirewall;
    };

    # Create jellyfin-specific directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.configDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.cacheDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.logDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    # Ensure the jellyfin user has access to media directories
    systemd.services.jellyfin = {
      serviceConfig = {
        SupplementaryGroups = [cfg.group];
      };
    };
  };
}
