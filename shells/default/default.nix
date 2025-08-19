{
  mkShell,
  inputs,
  system,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.universe; let
  inherit (inputs.self.hooks.${system}.pre-commit-check) shellHook;
in
  mkShell {
    buildInputs = with pkgs;
      [
        deadnix
        statix
        alejandra
        nix-diff
        nix-index
        nix-prefetch-git
        snowfallorg.flake
        statix
        zsh
      ]
      ++ inputs.self.hooks.${system}.pre-commit-check.enabledPackages;

    pure = true;

    shellHook = ''
      ${shellHook}
      echo 🌌 Gaze into the universe...
      # exec zsh
      #
      # Set up fzf for bash history search
      export FZF_DEFAULT_OPTS="--height 40% --reverse --border"

      # Bind Ctrl-R to fzf for history search
      # This replaces the default reverse-i-search with fzf
      # Load fzf keybindings and history search setup
      . ${pkgs.fzf}/share/fzf/key-bindings.bash
      # Include fzf completion (optional, helps with tab completion enhancements)
      . ${pkgs.fzf}/share/fzf/completion.bash
    '';
  }
