{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.system.time;
in {
  options.universe.system.time = with types; {
    enable =
      mkBoolOpt false "Whether or not to configure timezone information.";
    TZ = mkOpt str "America/New_York" "Timezone to set for system";
  };

  config = mkIf cfg.enable {time.timeZone = cfg.TZ;};
}
