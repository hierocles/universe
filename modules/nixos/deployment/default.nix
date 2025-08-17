{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.universe.deployment;
in {
  options.universe.deployment = {
    enable = mkEnableOption "Enable deployment configuration for deploy-rs";

    hostname = mkOption {
      type = types.str;
      default = "";
      description = "Hostname or IP address for deployment";
      example = "192.168.1.100";
    };

    fastConnection = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the connection to the target is fast";
    };

    sshUser = mkOption {
      type = types.str;
      default = "root";
      description = "SSH user for system deployment";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User for profile activation";
    };
  };

  config = mkIf cfg.enable {
    # This module doesn't directly configure the system
    # It's used by the flake to configure deploy-rs
  };
}
