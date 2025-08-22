{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.system.zsh;
in {
  options.universe.system.zsh = {enable = mkBoolOpt false "Whether or not to enable ZSH.";};

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
    };
  };
}
