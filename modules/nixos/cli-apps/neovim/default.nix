{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.universe.cli-apps.neovim;
in {
  options.universe.cli-apps.neovim = {enable = mkEnableOption "Neovim";};

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      less
      neovim
    ];
  };
}
