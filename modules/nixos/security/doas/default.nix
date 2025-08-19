{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.security.doas;
in {
  options.universe.security.doas = {
    enable = mkBoolOpt false "Whether or not to replace sudo with doas.";
  };

  config = mkIf cfg.enable {
    # Disable sudo
    security.sudo.enable = false;

    # Enable and configure `doas`.
    security.doas = {
      enable = true;
      extraRules = [
        {
          runAs = "root";
          cmd = "nixos-rebuild";
          users = [config.universe.user.name];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
    # Add an alias to the shell for backward-compat and convenience.
    environment.shellAliases = {sudo = "doas";};
  };
}
