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
      inherit (config.snowfallorg.user) name;
    };
    cli-apps = {
      zsh = enabled;
      home-manager = enabled;
    };
    tools = {
      git = enabled;
      direnv = {
        enable = true;
        configTOML = ''
          [global]
          hide_env_diff = true
          warn_timeout = "60s"
        '';
      };
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
