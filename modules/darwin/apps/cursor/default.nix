{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.cursor;
in {
  options.${namespace}.apps.cursor = with types; {
    enable = mkBoolOpt false "Whether or not to enable cursor.";
  };

  config = mkIf cfg.enable {
    programs.cursor.enable = true;
  };
}
