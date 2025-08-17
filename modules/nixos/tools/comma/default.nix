{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.comma;
in {
  options.${namespace}.tools.comma = with types; {
    enable = mkBoolOpt false "Whether or not to enable comma.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      comma
      universe.nix-update-index
    ];

    universe.home = {
      configFile = {
        "wgetrc".text = "";
      };
      extraOptions = {
        programs.nix-index.enable = true;
      };
    };
  };
}
