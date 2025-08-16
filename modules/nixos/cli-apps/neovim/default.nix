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
  cfg = config.${namespace}.cli-apps.neovim;
in {
  options.${namespace}.cli-apps.neovim = with types; {
    enable = mkBoolOpt true "Whether or not to enable neovim configuration.";
  };

  config = mkIf cfg.enable {
    programs.neovim.enable = true;

    environment.variables = {
      PAGER = "less";
      MANPAGER = "less";
      EDITOR = "nvim";
    };

    universe.home = {
      extraOptions = {
        # Use Neovim for Git diffs.
        programs.zsh.shellAliases.vimdiff = "nvim -d";
        programs.bash.shellAliases.vimdiff = "nvim -d";
        programs.fish.shellAliases.vimdiff = "nvim -d";
      };
    };
  };
}
