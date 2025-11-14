{
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.system.locale;
in {
  options.universe.system.locale = with types; {
    enable = mkBoolOpt false "Whether or not to manage locale settings.";
  };

  config = mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";

    console = {keyMap = mkForce "us";};
  };
}
