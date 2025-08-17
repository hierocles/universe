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
    loader = mkOption {
      type = enum ["systemd-boot" "grub"];
      default = "systemd-boot";
      description = "The boot loader to use.";
    };
    efi = mkBoolOpt true "Whether to enable EFI support.";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.loader == "systemd-boot") {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = cfg.efi;
      };
    })

    (mkIf (cfg.loader == "grub") {
      boot.loader = {
        grub = {
          enable = true;
          efiSupport = cfg.efi;
          efiInstallAsRemovable = cfg.efi;
        };
        efi.canTouchEfiVariables = cfg.efi;
      };
    })
  ]);
}
