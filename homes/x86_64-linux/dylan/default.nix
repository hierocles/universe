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
      name = "dylan";
      fullName = "Dylan Henrich";
      email = "4733259+hierocles@users.noreply.github.com";
    };
    archetypes = {
      headless = enabled;
    };
  };

  home = {
    sessionPath = ["$HOME/bin"];
    stateVersion = "25.05";
  };
}
