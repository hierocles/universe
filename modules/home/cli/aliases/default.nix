{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.universe; let
  # Generated file content for aliases
  aliasesFile =
    pkgs.writeText "aliases.shrc"
    "${convertAlias config.universe.cli.aliases}";

  default-aliases = pkgs.writeText "default-aliases.shrc" (convertAlias {
    ".." = "cd ..";
    "cd.." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "--" = "cd -";
    mv = "mv -v";
    rm = "rm -i -v";
    cp = "cp -v";
    la = "${pkgs.lsd}/bin/lsd -laF --group-dirs first";
    ls = "${pkgs.lsd}/bin/lsd --tree --depth 3";
    df = "df -h";
    chmox = "chmod -x";
    status = "sudo systemctl status";
    start = "sudo systemctl start";
    stop = "sudo systemctl stop";
    restart = "sudo systemctl restart";
    disable = "sudo systemctl disable";
    enable = "sudo systemctl enable";
    flake-update = ''${pkgs.nix}/bin/nix flake update --option access-tokens "github.com=$GITHUB_TOKEN"'';
    kill = ''
      [ $# -eq 0 ] && echo 'You need to specify whom to kill.' && return
            /usr/bin/kill $@'';
  });
in {
  options.universe.cli.aliases = with types;
    mkOption {
      type = attrsOf str;
      default = {};
      description = "A set of command aliases to set.";
    };

  config = {
    # Source the alias file in the shell configuration
    programs.zsh.initContent = lib.mkAfter ''
      source ${default-aliases}
      source ${aliasesFile}
    '';
  };
}
