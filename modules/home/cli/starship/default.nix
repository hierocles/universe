{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.universe; let
  inherit (lib) mkIf;

  cfg = config.${namespace}.cli.starship;
in {
  options.${namespace}.cli.starship = {
    enable = mkBoolOpt false "Whether or not to enable starship.";
  };

  config = mkIf cfg.enable {
    xdg.configFile."starship/starship.toml".source = ./starship.toml;

    programs.starship.enable = true;
  };
}
