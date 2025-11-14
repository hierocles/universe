{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.nil;
in {
  options.${namespace}.tools.nil = with types; {
    enable = mkBoolOpt false "Whether or not to install nil.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nil
    ];
  };
}
