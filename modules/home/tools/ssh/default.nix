{
  lib,
  config,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.tools.ssh;
in {
  options.${namespace}.tools.ssh = {
    enable = mkEnableOption "SSH";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      extraConfig = ''
        Host *
          HostKeyAlgorithms +ssh-rsa
      '';
    };
  };
}
