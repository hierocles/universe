{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.system.boot;
in {
  options.${namespace}.system.boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable boot configuration.";
    efi = mkBoolOpt true "Whether to enable EFI support.";
  };

  config = mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = cfg.efi;
    };
  };
}
