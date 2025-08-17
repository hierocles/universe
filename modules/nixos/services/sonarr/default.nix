{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.sonarr;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.sonarr = with types; {
    enable = mkBoolOpt false "Whether or not to enable Sonarr.";

    port = mkOption {
      type = port;
      default = 8989;
      description = "Port for Sonarr web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Sonarr.";
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.sonarr = {
      enable = true;
      inherit (arrCfg) user group;
      dataDir = "${arrCfg.configPath}/sonarr";
    };

    # Override the default port if changed
    services.sonarr.openFirewall = cfg.openFirewall;

    # Create sonarr-specific config directory
    systemd.tmpfiles.rules = [
      "d ${arrCfg.configPath}/sonarr 0755 ${arrCfg.user} ${arrCfg.group} -"
    ];

    # Firewall configuration
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];
  };
}
