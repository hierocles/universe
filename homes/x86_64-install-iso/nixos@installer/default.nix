{
  lib,
  config,
  ...
}:
with lib.universe; {
  universe = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    cli = {
      zsh = enabled;
      home-manager = enabled;
      env = enabled;
    };
  };
  home.stateVersion = "25.05";
}
