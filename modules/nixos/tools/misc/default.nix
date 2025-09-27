{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.tools.misc;
in {
  options.universe.tools.misc = with types; {
    enable = mkBoolOpt false "Whether or not to enable common utilities.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fzf
      killall
      unzip
      file
      jq
      wget
      ripgrep
      bat
      ranger
      git
      gh
      rsync
      tldr
      zig
      btop
      deno
      devour
      usbutils
      pciutils
      neofetch
      libnotify
      bash
      lsof
      hwinfo
      traceroute
      tmux
      cntr
      glibc
    ];
  };
}
