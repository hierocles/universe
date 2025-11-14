{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.git;
  inherit (config.${namespace}.security) gpg;
  inherit (config.${namespace}) user;
in {
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable git configuration.";
    name = mkOpt types.str user.name "The name to use for git.";
    email = mkOpt types.str user.email "The email to use for git.";
    signingKey = mkOpt types.str gpg.default-key "The signing key to use for git.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
    ];

    universe.home.extraOptions = {
      programs.git = {
        enable = true;
        inherit (cfg) name email;
        lfs = enabled;
        signing = {
          key = cfg.signingKey;
          signByDefault = mkIf gpg.enable true;
        };
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          core.whitespace = "trailing-space,space-before-tab";
        };
      };
    };
  };
}
