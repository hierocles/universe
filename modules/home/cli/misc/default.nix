{
  options,
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
    universe.cli.aliases = {
      ls = "${pkgs.lsd}/bin/lsd --group-dirs first $@";
      la = "${pkgs.lsd}/bin/lsd -laF --group-dirs first $@";
      lt = "${pkgs.lsd}/bin/lsd --tree --depth 3 $@";
      cat = "${pkgs.bat}/bin/bat $@";
      pcat = "${pkgs.bat}/bin/bat -p $@";
      grep = "${pkgs.gnugrep}/bin/grep --color=auto $@";
    };
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
