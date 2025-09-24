{
  lib,
  pkgs,
  ...
}: let
  transmission-next-ui = pkgs.buildNpmPackage rec {
    pname = "transmission-next-ui";
    version = "v0.1.7";

    src = pkgs.fetchFromGitHub {
      owner = "hisproc";
      repo = "transmission-next-ui";
      tag = version;
      hash = "sha256-3cvM0bhJHa0fAK3JYOnHdkdrItY/8EIn7cBZRFlfkRk=";
    };

    npmDepsHash = "sha256-5xHh8BqLsxaLK/bqNJlPuzPJ4b8lXjdQgpNeMIfsOGM=";

    strictDeps = true;

    # Build the frontend assets
    buildPhase = ''
      runHook preBuild
      npm run build
      runHook postBuild
    '';

    # Install the built static files
    installPhase = ''
      runHook preInstall

      # Copy the built static files to the output directory
      mkdir -p $out
      cp -r dist/* $out/ || cp -r build/* $out/ || cp -r public/* $out/

      runHook postInstall
    '';

    meta = with lib; {
      description = "A modern web UI for Transmission";
      homepage = "https://github.com/hisproc/transmission-next-ui";
      downloadPage = "https://github.com/hisproc/transmission-next-ui/releases";
      license = licenses.mit;
      maintainers = [hierocles];
      platforms = platforms.all;
    };
  };
in
  transmission-next-ui
