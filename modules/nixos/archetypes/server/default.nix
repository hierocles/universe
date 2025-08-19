{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.archetypes.server;
in {
  options.universe.archetypes.server = with types; {
    enable = mkBoolOpt false "Whether or not to enable the server archetype.";
    hostId = mkOpt str "" "ZFS Host ID";
  };

  config = mkIf cfg.enable {
    universe = {
      suites = {
        common = enabled;
        #observability = enabled;
      };
      system = {
        zfs = {
          enable = true;
          hostId = cfg.hostId;
        };
      };
      services = {
        openssh = {
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIt0bjd1TRJ18rMizFAQVz5MU5oDIagcLw0cfio4zaZd dylan@andromeda"
          ];
        };
      };
    };
  };
}
