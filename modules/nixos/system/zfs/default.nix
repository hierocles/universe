{
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.system.zfs;
in {
  options.universe.system.zfs = with types; {
    enable = mkBoolOpt false "Whether or not to configure zfs.";
    hostId = mkOpt str "12345678" "The output of head -c 8 /etc/machine-id";
  };

  config = mkIf cfg.enable {
    boot.supportedFilesystems = ["zfs"];
    services.zfs.autoScrub.enable = true;
    #boot.kernelPackages = config.boot.zfs.package.linuxPackages_6_15;
    networking.hostId = cfg.hostId;
    services.zfs.autoSnapshot.enable = true;
  };
}
