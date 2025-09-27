{lib, ...}: let
  inherit (lib.universe) enabled;
in {
  universe = {
    user = {
      enable = true;
      name = "dylan";
    };

    cli = {
      ghostty = enabled;
      fish = enabled;
      starship = enabled;
      tmux = enabled;
      home-manager = enabled;
      nixvim = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      ssh = enabled;
    };
  };

  home.sessionPath = ["$HOME/bin"];

  home.stateVersion = "24.11";
}
