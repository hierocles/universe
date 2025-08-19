{
  options,
  config,
  inputs,
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
      lsd
      git
      rsync
      tldr
      zig
      btop
      deno
      flameshot
      neovim
      devour
      usbutils
      pciutils
      neofetch
      libnotify
      bash
      lsof
      hwinfo
      traceroute
      gptfdisk
      parted
      tmux
      cntr
      glibc
      smartmontools
      lshw
      yt-dlp
    ];
  };
}
