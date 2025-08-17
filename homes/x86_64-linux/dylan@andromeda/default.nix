{
  lib,
  pkgs,
  config,
  namespace,
  osConfig,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    user = {
      enable = true;
      name = config.snowfallorg.user.name;
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

  # Use basic neovim for now to avoid module issues
  home.packages = with pkgs; [
    neovim
  ];

  home.sessionPath = ["$HOME/bin"];
  home.stateVersion = "25.05";
}
