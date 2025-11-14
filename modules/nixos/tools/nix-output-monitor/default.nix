{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.tools.nix-output-monitor;
in {
  options.universe.tools.nix-output-monitor = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable common Nix Output Monitor.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [nix-output-monitor];
  };
}
