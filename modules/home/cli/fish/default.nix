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

  cfg = config.${namespace}.cli.fish;
in {
  options.${namespace}.cli.fish = {
    enable = mkBoolOpt false "Whether or not to enable ZSH.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.fish];
    programs = {
      fish = {
        enable = true;
        generateCompletions = true;
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
        plugins = [
          {
            name = "z";
            inherit (pkgs.fishPlugins.z) src;
          }
          {
            name = "fzf";
            inherit (pkgs.fishPlugins.fzf) src;
          }
          {
            name = "fish-you-should-use";
            inherit (pkgs.fishPlugins.fish-you-should-use) src;
          }
          {
            name = "plugin-git";
            inherit (pkgs.fishPlugins.plugin-git) src;
          }
        ];
      };
      eza = {
        enableFishIntegration = true;
        enable = true;
      };
      ghostty.enableFishIntegration = lib.mkIf config.${namespace}.cli.ghostty.enable {
        enable = true;
      };
      nix-index.enableFishIntegration = true;
      starship = lib.mkIf config.${namespace}.cli.starship.enable {
        enableFishIntegration = true;
        enableTransience = true;
      };
    };
  };
}
