{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.cli.misc;
in {
  options.universe.cli.misc = with types; {
    enable = mkBoolOpt false "Whether or not to misc cli programs.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nurl
      ripgrep-all
      ripgrep
      fzf
      killall
      unzip
      file
      jq
      wget
      bat
      lsd
      rsync
      tldr
      gcc
      zig
      btop
      deno
      devour
    ];
  };
}
