{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./hardware-configuration.nix
  ];

  universe = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };
    cli-apps = {
      zsh = enabled;
      home-manager = enabled;
    };
    tools = {
      git = enabled;
      direnv = enabled;
    };
  };

  home = {
    packages = with pkgs; [
      neovim
    ];
    sessionPath = ["$HOME/bin"];
    stateVersion = "25.05";
  };
}
