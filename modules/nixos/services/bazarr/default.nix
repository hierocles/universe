{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.bazarr;
  arrCfg = config.${namespace}.services.arr;
in {
  options.${namespace}.services.bazarr = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bazarr.";

    port = mkOption {
      type = port;
      default = 6767;
      description = "Port for Bazarr web interface.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall for Bazarr.";
  };

  config = mkIf cfg.enable {
    # Ensure base *arr config is enabled
    ${namespace}.services.arr.enable = mkDefault true;

    services.bazarr = {
      enable = true;
      inherit (arrCfg) user group;
    };

    # Create bazarr-specific config directory
    systemd.tmpfiles.rules = [
      "d ${arrCfg.configPath}/bazarr 0755 ${arrCfg.user} ${arrCfg.group} -"
    ];

    # Firewall configuration
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];
  };
}
