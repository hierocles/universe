{
  lib,
  config,
  namespace,
  ...
}: let
  cfg = config.${namespace}.desktop.yabai;

  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.${namespace}) mkOpt enabled;
in {
  options.${namespace}.desktop.yabai = {
    enable = mkEnableOption "Yabai";
    enable-scripting-addition =
      mkOpt types.bool true
      "Whether to enable the scripting addition for Yabai. (Requires SIP to be disabled)";
  };

  config = mkIf cfg.enable {
    universe.desktop.addons = {
      skhd = enabled;
      spacebar = enabled;
    };

    services.yabai = {
      enable = true;
      enableScriptingAddition = cfg.enable-scripting-addition;

      config = {
        layout = "bsp";

        auto_balance = "off";

        debug_output = "on";

        top_padding = 8;
        right_padding = 8;
        left_padding = 8;
        bottom_padding = 8;

        window_gap = 6;
        window_topmost = "on";
        window_shadow = "float";
        window_border = "off";

        external_bar = "all:${builtins.toString config.services.spacebar.config.height}:0";

        mouse_modifier = "cmd";
        mouse_action1 = "move";
        mouse_action2 = "resize";
      };

      extraConfig = ''
        yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        yabai -m rule --add label="System Preferences" app="^System Preferences$" title=".*" manage=off
        yabai -m rule --add label="App Store" app="^App Store$" manage=off
        yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
        yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
        yabai -m rule --add label="Dictionary" app="^Dictionary$" manage=off
        yabai -m rule --add label="mpv" app="^mpv$" manage=off
        yabai -m rule --add label="Software Update" title="Software Update" manage=off
        yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
      '';
    };
  };
}
