{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.cursor-server;
in {
  options.${namespace}.tools.vscode-server = with types; {
    enable = mkBoolOpt false "Whether or not to enable vscode-server.";
  };

  config = mkIf cfg.enable {
    services.vscode-server.enable = true;
  };
}
