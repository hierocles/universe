{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.universe; let
  inherit (lib) mkIf;

  cfg = config.${namespace}.cli.zsh;

  tty-color-support = with lib.${namespace}.colors; ''
    if [ "$TERM" = "linux" ]; then
      echo -ne "\e]P0${without-hash gruvbox-dark.black}" # black
      echo -ne "\e]P8${without-hash gruvbox-dark.dark-grey}" # darkgrey
      echo -ne "\e]P1${without-hash gruvbox-dark.dark-red}" # darkred
      echo -ne "\e]P9${without-hash gruvbox-dark.red}" # red
      echo -ne "\e]P2${without-hash gruvbox-dark.dark-green}" # darkgreen
      echo -ne "\e]PA${without-hash gruvbox-dark.green}" # green
      echo -ne "\e]P3${without-hash gruvbox-dark.dark-yellow}" # brown
      echo -ne "\e]PB${without-hash gruvbox-dark.yellow}" # yellow
      echo -ne "\e]P4${without-hash gruvbox-dark.dark-blue}" # darkblue
      echo -ne "\e]PC${without-hash gruvbox-dark.blue}" # blue
      echo -ne "\e]P5${without-hash gruvbox-dark.dark-magenta}" # darkmagenta
      echo -ne "\e]PD${without-hash gruvbox-dark.magenta}" # magenta
      echo -ne "\e]P6${without-hash gruvbox-dark.dark-cyan}" # darkcyan
      echo -ne "\e]PE${without-hash gruvbox-dark.cyan}" # cyan
      echo -ne "\e]P7${without-hash gruvbox-dark.light-grey}" # lightgrey
      echo -ne "\e]PF${without-hash gruvbox-dark.white}" # white
      clear
    fi
  '';
in {
  options.${namespace}.cli.zsh = {
    enable = mkBoolOpt false "Whether or not to enable ZSH.";
  };

  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        shellAliases = {
          ".." = "cd ..";
          "cd.." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "--" = "cd -";
          mv = "mv -v";
          rm = "rm -i -v";
          cp = "cp -v";
          cat = "bat";
          ld = "eza -ld */ --no-quotes --time-style long-iso";
          lla = "eza -lah --no-quotes --time-style long-iso";
          ll = "eza -lh --no-quotes --time-style long-iso";
          llr = "eza -lhr --no-quotes --time-style long-iso";
          lls = "eza -lh -s size --no-quotes --time-style long-iso";
          llt = "eza -lh -s time --no-quotes --time-style long-iso";
          lltr = "eza -lhr -s time --no-quotes --time-style long-iso";
          df = "df -h";
        };
        initContent = ''
          # Fix an issue with tmux.
          export KEYTIMEOUT=1

          # Auto-start tmux if not already in tmux and not in SSH
          if [[ -z "$TMUX" ]] && [[ -z "$SSH_CLIENT" ]] && [[ -z "$SSH_TTY" ]] && command -v tmux >/dev/null 2>&1; then
            exec tmux new-session -A -s main
          fi

          ${tty-color-support}
        '';
        plugins = [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.4.0";
              sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
            };
          }
        ];
      };
      eza = {
        enableZshIntegration = true;
        enable = true;
      };
      ghostty.enableZshIntegration = lib.mkIf config.${namespace}.cli.ghostty.enable {
        enable = true;
      };
      nix-index.enableZshIntegration = true;
      starship = lib.mkIf config.${namespace}.cli.starship.enable {
        enableZshIntegration = true;
      };
    };
  };
}
