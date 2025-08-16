{
  options,
  config,
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli-apps.nixvim;
in {
  options.${namespace}.cli-apps.nixvim = with types; {
    enable = mkBoolOpt true "Whether or not to enable nixvim configuration.";
  };

  config = mkIf cfg.enable {
    programs.nixvim.enable = true;

    environment.variables = {
      PAGER = "less";
      MANPAGER = "less";
      EDITOR = "nvim";
    };

    universe.home = {
      extraOptions = {
        # Use Neovim or Git diffs.
        programs.zsh.shellAliases.vimdiff = "nvim -d";
        programs.bash.shellAliases.vimdiff = "nvim -d";
        programs.fish.shellAliases.vimdiff = "nvim -d";
      };
    };
  };
}
