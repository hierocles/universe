{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;

  cfg = config.universe.archetypes.wsl;
in {
  options.universe.archetypes.wsl = {
    enable = lib.mkEnableOption "the wsl archetype";
  };

  config = mkIf cfg.enable {
    environment = {
      sessionVariables = {
        BROWSER = "wsl-open";
      };

      systemPackages = with pkgs; [
        dos2unix
        wsl-open
        wslu
      ];
    };
    # Limit to main fonts only
    fonts.packages = mkForce (
      with pkgs; [
        monaspace
        nerd-fonts.symbols-only
      ]
    );
  };
}
