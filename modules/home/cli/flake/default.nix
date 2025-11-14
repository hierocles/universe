{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.cli.flake;
in {
  options.universe.cli.flake = with types; {
    enable = mkBoolOpt false "Whether or not to enable flake.";
  };

  config =
    mkIf cfg.enable {home.packages = with pkgs; [snowfallorg.flake];};
}
