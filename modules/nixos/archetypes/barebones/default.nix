{
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.archetypes.barebones;
in {
  options.universe.archetypes.barebones = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable the barebones archetype.";
  };

  config =
    mkIf cfg.enable {universe = {suites = {common = enabled;};};};
}
