{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.homebrew;
in {
  options.${namespace}.tools.homebrew = with types; {
    enable = mkBoolOpt false "Whether or not to enable Homebrew.";
  };

  config = mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = config.${namespace}.user.name;
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };
      mutableTaps = true;
    };

    homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
  };
}
