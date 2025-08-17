{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.radarr;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.radarr = with types; {
    enable = mkBoolOpt false "Whether or not to enable Radarr.";

    port = mkOption {
      type = port;
      default = 7878;
      description = "Port for Radarr web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Radarr.";
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.radarr = {
      enable = true;
      inherit (arrCfg) user group;
      dataDir = "${arrCfg.configPath}/radarr";
    };

    # Override the default port if changed
    services.radarr.openFirewall = cfg.openFirewall;

    # Create radarr-specific config directory
    systemd.tmpfiles.rules = [
      "d ${arrCfg.configPath}/radarr 0755 ${arrCfg.user} ${arrCfg.group} -"
    ];

    # Firewall configuration
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];
  };
}
