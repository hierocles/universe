{
  config,
  lib,
  ...
}: let
  inherit (lib.universe) enabled;
in {
  universe = {
    user = {
      enable = true;
      name = "dylan";
    };

    services = {
      sops = {
        enable = false;
        defaultSopsFile = lib.getFile "secrets/secrets.yaml";
        sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      };
    };
  };

  home.stateVersion = "24.11";
}
