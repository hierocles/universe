{
  lib,
  pkgs,
  config,
  osConfig ? {},
  format ? "unknown",
  ...
}:
with lib.universe; {
  universe = {
    user = {
      enable = true;
      name = config.snowfallorg.user.name;
    };

    cli = {
      zsh = enabled;
      home-manager = enabled;
      env = enabled;
    };
  };
  home.stateVersion = "25.05";
}
