{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.thelounge;
in {
  options.${namespace}.services.thelounge = with types; {
    enable = mkBoolOpt false "Whether or not to enable The Lounge.";
    public = mkBoolOpt false "Whether or not to allow public access to The Lounge.";
    port = mkOpt port 1337 "The port to listen on.";
    extraConfig = mkOpt attrs {} "Extra configuration for The Lounge.";
    plugins = mkOpt (listOf str) [] "The plugins to install.";
  };

  config = mkIf cfg.enable {
    services.thelounge = {
      enable = true;
      inherit (cfg) public port extraConfig plugins;
    };
  };
}
