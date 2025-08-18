{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.direnv;
in {
  options.${namespace}.tools.direnv = with types; {
    enable = mkBoolOpt false "Whether or not to enable direnv.";
    configTOML = mkOpt (types.nullOr types.str) null "TOML configuration for direnv.";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
      config = mkForce (mkIf (cfg.configTOML != null) cfg.configTOML);
    };
  };
}
