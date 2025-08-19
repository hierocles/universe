{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.tools.nix-doc;
in {
  options.universe.tools.nix-doc = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-doc.";
  };

  config = mkIf cfg.enable {
    nix.extraOptions = ''
      plugin-files = ${pkgs.nix-doc}/lib/libnix_doc_plugin.so
    '';

    environment.systemPackages = with pkgs; [nix-doc];
  };
}
