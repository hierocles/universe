{
  inputs,
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.universe; let
  cfg-user = config.universe.user;
  is-darwin = pkgs.stdenv.isDarwin;

  # aliases = import ./aliases.nix { inherit pkgs; };
  home-directory =
    if cfg-user.name == null
    then null
    else if is-darwin
    then "/Users/${cfg-user.name}"
    else "/home/${cfg-user.name}";
in {
  options.universe.cli.env = with types;
    mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (_n: v:
        if isList v
        then concatMapStringsSep ":" (x: toString x) v
        else (toString v));
      default = {};
      description = "A set of environment variables to set.";
    };

  config = {
    home.sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      XDG_CONFIG_HOME = "${home-directory}/.config";
      XDG_DATA_HOME = "${home-directory}/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_CACHE_HOME = mkDefault "$HOME/.cache";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    };
  };
}
