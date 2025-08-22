{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.cli.neovim;
in {
  options.${namespace}.cli.neovim = {
    enable = mkEnableOption "Neovim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # Additional packages
    home.packages = with pkgs; [
      # LSP servers
      nil # Nix LSP

      # Formatters
      alejandra # Nix formatter

      # Linters
      statix # Nix linter

      # Tree-sitter
      tree-sitter

      # Additional tools
      ripgrep
      fd
      fzf
      bat
      delta
      nvim-pkg
    ];

    # Session variables
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Shell aliases
    programs.zsh.shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
      vi = "nvim";
    };
  };
}
