{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.cursor-server;
in {
  options.${namespace}.tools.cursor-server = with types; {
    enable = mkBoolOpt false "Whether or not to enable cursor-server.";
  };

  config = mkIf cfg.enable {
    services.cursor-server.enable = true;
  };
}
