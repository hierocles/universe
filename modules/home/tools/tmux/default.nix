{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.tools.tmux;
in {
  options.universe.tools.tmux = with types; {
    enable = mkBoolOpt false "Whether to enable tmux.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 100000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      escapeTime = 0;
      aggressiveResize = true;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        resurrect
        continuum
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"
            set -g @catppuccin_status_modules_right "directory session"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_directory_text "#{pane_current_path}"
          '';
        }
      ];

      extraConfig = ''
        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Better pane splitting
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Pane navigation with vim-like keys
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Pane resizing
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Window navigation
        bind -n M-H previous-window
        bind -n M-L next-window

        # New window with current path
        bind c new-window -c "#{pane_current_path}"

        # Copy mode improvements
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
        bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

        # Enable true color support
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"

        # Status bar updates
        set -g status-interval 1

        # Start windows and panes at 1
        set -g base-index 1
        setw -g pane-base-index 1

        # Renumber windows when one is closed
        set -g renumber-windows on

        # Session persistence
        set -g @resurrect-capture-pane-contents 'on'
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
        set -g @continuum-save-interval '15'

        # Better search
        bind-key / copy-mode \; send-key ?
      '';
    };
  };
}
