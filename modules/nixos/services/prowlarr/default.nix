{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.prowlarr;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.prowlarr = with types; {
    enable = mkBoolOpt false "Whether or not to enable Prowlarr.";

    port = mkOption {
      type = port;
      default = 9696;
      description = "Port for Prowlarr web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Prowlarr.";
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.prowlarr = {
      enable = true;
      dataDir = "${arrCfg.configPath}/prowlarr";
      inherit (cfg) openFirewall;
      settings.server.port = cfg.port;
    };

    # Create prowlarr-specific config directory
    systemd.tmpfiles.rules = [
      "d ${arrCfg.configPath}/prowlarr 0755 ${arrCfg.user} ${arrCfg.group} -"
    ];
  };
}
