{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  universe = {
    user = {
      enable = true;
      name = "dylan";
      fullName = "Dylan Henrich";
      email = "4733259+hierocles@users.noreply.github.com";
    };
    archetypes = {
      headless = enabled;
    };
    services.openssh = {
      enable = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIt0bjd1TRJ18rMizFAQVz5MU5oDIagcLw0cfio4zaZd dylan@andromeda"
      ];
      manage-other-hosts = true;
      extraConfigs = ''
        Host 192.168.8.115
          User dylan
          IdentityFile ~/.ssh/id_andromeda
          ForwardAgent yes
          IdentitiesOnly yes
      '';
    };
  };

  home = {
    sessionPath = ["$HOME/bin"];
    stateVersion = "25.05";
  };
}
