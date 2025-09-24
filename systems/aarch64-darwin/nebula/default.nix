{
  lib,
  config,
  ...
}: let
  inherit (lib.universe) enabled;

  cfg = config.universe.user;
in {
  universe = {};

  nix.settings = {
    cores = 10;
    max-jobs = 3;
  };

  system = {
    primaryUser = "dylan";
    stateVersion = 5;
  };
}
