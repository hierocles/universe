{
  lib,
  config,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.archetypes.headless;
in {
  options.universe.archetypes.headless = with types; {
    enable = mkEnableOption "headless home enviornment";
  };

  config = mkIf cfg.enable {
    universe = {
      services = {
        openssh = enabled;
      };
      cli = {
        flake = enabled;
        misc = enabled;
        neovim = enabled;
        zsh = enabled;
        home-manager = enabled;
      };

      tools = {
        git = enabled;
        ssh = enabled;
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
  };
}
