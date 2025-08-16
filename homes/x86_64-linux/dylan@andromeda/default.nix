{
  lib,
  pkgs,
  config,
  namespace,
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
      nixvim = enabled;
      home-manager = enabled;
    };
    tools = {
      git = enabled;
      direnv = enabled;
    };
  };

  home.sessionPath = ["$HOME/bin"];
  home.stateVersion = "25.05";
}
