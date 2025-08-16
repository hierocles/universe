{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.cli-apps.nixvim;
in {
  options.${namespace}.cli-apps.nixvim = {
    enable = mkEnableOption "Nixvim";
  };

  config = mkIf cfg.enable {
    programs.nixvim.enable = true;

    home = {
      packages = with pkgs; [
        less
      ];

      sessionVariables = {
        PAGER = "less";
        MANPAGER = "less";
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        EDITOR = "nvim";
      };

      shellAliases = {
        vimdiff = "nvim -d";
      };
    };

    xdg.configFile = {
      "dashboard-nvim/.keep".text = "";
    };
  };
}
