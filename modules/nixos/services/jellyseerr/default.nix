{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.jellyseerr;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.jellyseerr = with types; {
    enable = mkBoolOpt false "Whether or not to enable Jellyseerr.";

    port = mkOption {
      type = port;
      default = 5055;
      description = "Port for Jellyseerr web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Jellyseerr.";
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.jellyseerr = {
      enable = true;
      configDir = "${arrCfg.configPath}/jellyseerr";
      inherit (cfg) port openFirewall;
    };

    # Create jellyseerr-specific config directory
    systemd.tmpfiles.rules = [
      "d ${arrCfg.configPath}/jellyseerr 0755 ${arrCfg.user} ${arrCfg.group} -"
    ];
  };
}
