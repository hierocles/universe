{
  pkgs,
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.universe; let
  # Generated file content for aliases
  aliasesFile =
    pkgs.writeText "aliases.shrc"
    "${convertAlias config.universe.system.aliases}";
in {
  options.universe.system.aliases = with types;
    mkOption {
      type = attrsOf str;
      default = {};
      description = "A set of command aliases to set.";
    };
  options.universe.system.env = with types;
    mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (_n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "A set of environment variables to set.";
    };

  config = {
    environment = {
      sessionVariables = {
        NIXOS_CONFIG = "/config";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_BIN_HOME = "$HOME/.local/bin";
        # To prevent firefox from creating ~/Desktop.
        XDG_DESKTOP_DIR = "$HOME";
        EDITOR = "nvim";
      };
      variables = {
        # Make some programs "XDG" compliant.
        LESSHISTFILE = "$XDG_CACHE_HOME/less.history";
        WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      };
      extraInit = lib.mkAfter ''
        source ${aliasesFile}
      '';
    };
  };
}
