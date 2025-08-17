{...}: rec {
  colors = {
    without-hash = color: builtins.substring 1 (builtins.stringLength color) color;

    nord = {
      nord0 = "#2E3440";
      nord1 = "#3B4252";
      nord2 = "#434C5E";
      nord3 = "#4C566A";
      nord4 = "#D8DEE9";
      nord5 = "#E5E9F0";
      nord6 = "#ECEFF4";
      nord7 = "#8FBCBB";
      nord8 = "#88C0D0";
      nord9 = "#81A1C1";
      nord10 = "#5E81AC";
      nord11 = "#BF616A";
      nord12 = "#D08770";
      nord13 = "#EBCB8B";
      nord14 = "#A3BE8C";
      nord15 = "#B48EAD";
    };

    gruvbox-dark = {
      black = "#1d2021"; # Hard contrast
      white = "#ebdbb2";
      light-grey = "#a89984";
      dark-grey = "#928374";
      red = "#fb4934";
      dark-red = "#cc241d";
      green = "#b8bb26";
      dark-green = "#98971a";
      yellow = "#fabd2f";
      dark-yellow = "#d79921";
      blue = "#83a598";
      dark-blue = "#458588";
      magenta = "#d3869b";
      dark-magenta = "#b16286";
      cyan = "#8ec07c";
      dark-cyan = "#689d6a";
    };
  };
}
