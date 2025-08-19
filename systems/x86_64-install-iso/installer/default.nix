{
  pkgs,
  inputs,
  lib,
  nixos-hardware,
  nixosModules,
  ...
}:
with lib;
with lib.universe; let
  newUser = name: {
    isNormalUser = true;
    createHome = true;
    home = "/home/${name}";
    shell = pkgs.zsh;
  };
in {
  home-manager.users.nixos.snowfallorg.user.name = "nixos";
  # boot.loader.grub = enabled;

  boot.kernelModules = ["igb"];

  networking.wireless.enable = false;
  universe = {
    nix = enabled;
    archetypes = {barebones = enabled;};
    # cli-apps = {flake = enabled;}; # Temporarily disabled due to flake check issues
    tools = {
      git = enabled;
      misc = enabled;
    };
    services = {openssh = enabled;};

    system = {
      locale = enabled;
      time = enabled;
      xkb = enabled;
      zfs = enabled;
    };
    user = {
      name = "nixos";
      fullName = "Dylan Henrich";
      email = "4733259+hierocles@users.noreply.github.com";
      extraGroups = ["wheel"];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
