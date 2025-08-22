{
  mkShell,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.universe;
  mkShell {
    buildInputs = with pkgs; [
      deploy-rs
      zsh
      sops
      nix-output-monitor
    ];
    pure = true;

    shellHook = ''
      clear
      echo -e "\e[1;32m+-----------------------------------------------------------+\e[0m"
      echo -e "\e[1;32m|        🌌 Welcome to the Universe Deploy Shell            |\e[0m"
      echo -e "\e[1;32m+-----------------------------------------------------------+\e[0m"
      echo -e "\e[1;36m|     🚀 Ready to deploy and configure your systems!        |\e[0m"
      echo -e "\e[1;34m|      Quick Commands:                                      |\e[0m"
      echo -e "\e[1;34m|      🔹 deploy --hostname <hostname|ip>                   |\e[0m"
      echo -e "\e[1;34m|          github:hierocles/universe#<hostname>             |\e[0m"
      echo -e "\e[1;34m|          --skip-checks                                    |\e[0m"
      echo -e "\e[1;36m|                                                           |\e[0m"
      echo -e "\e[1;32m+-----------------------------------------------------------+\e[0m"
    '';
  }
