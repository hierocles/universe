{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.system.wsl;
in {
  options.${namespace}.system.wsl = with types; {
    enable = mkBoolOpt true "Whether or not to manage WSL configuration.";
    default-user = mkOpt str "root" "The default user to use for wsl.";
  };

  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = cfg.default-user;
    };
  };
}
