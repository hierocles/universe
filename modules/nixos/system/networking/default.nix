{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.system.networking;
in {
  options.${namespace}.system.networking = with types; {
    enable = mkBoolOpt false "Whether or not to enable networking configuration.";
    hostId = mkOpt (nullOr str) null "The unique host ID for this system (required for ZFS).";
  };

  config = mkIf cfg.enable {
    networking = mkMerge [
      (mkIf (cfg.hostId != null) {
        inherit (cfg) hostId;
      })
    ];
  };
}
