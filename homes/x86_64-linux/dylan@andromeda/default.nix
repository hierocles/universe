{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    user = {
      enable = true;
      name = config.snowfallorg.user.name;
    };
    cli-apps = {
      zsh = enabled;
      home-manager = enabled;
    };
    tools = {
      git = enabled;
      direnv = enabled;
    };
  };

  # Use basic neovim for now to avoid module issues
  home.packages = with pkgs; [
    neovim
  ];

  # GPG public key for commit signing (now managed by SOPS)
  home.file.".gnupg/dylan-gpg-public.asc".source = config.sops.secrets."users/dylan/gpg-public-key".path;

  home.sessionPath = ["$HOME/bin"];
  home.stateVersion = "25.05";
}
