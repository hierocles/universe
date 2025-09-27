{lib, ...}: let
  inherit (lib.universe) enabled;
in {
  universe = {
    suites = {
      common = enabled;
      development = enabled;
    };

    desktop.yabai = enabled;
  };

  environment.systemPath = ["/opt/homebrew/bin"];
  system.stateVersion = 5;
}
