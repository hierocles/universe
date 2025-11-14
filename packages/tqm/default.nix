{
  lib,
  pkgs,
  ...
}: let
  tqm = pkgs.buildGoModule rec {
    pname = "tqm";
    version = "1.17.0";

    src = pkgs.fetchFromGitHub {
      owner = "autobrr";
      repo = "tqm";
      rev = "v${version}";
      hash = "sha256-4zbv8VoCf95xteGdgMiS+cw/nawoYwzksSXXKK0r06M=";
    };

    vendorHash = "sha256-IUAqY4w0Akm1lJJU5fZkVQpc5fWUx/88+hAinwZN3y4=";

    # Tests require filesystem access which isn't available in the build sandbox
    doCheck = false;

    ldflags = [
      "-s"
      "-w"
      "-X github.com/autobrr/tqm/pkg/runtime.Version=${version}"
    ];

    meta = with lib; {
      description = "Torrent Queue Manager - CLI utility for managing torrent client queues";
      homepage = "https://github.com/autobrr/tqm";
      downloadPage = "https://github.com/autobrr/tqm/releases";
      license = licenses.gpl3Only;
      maintainers = [hierocles];
      mainProgram = "tqm";
      platforms = platforms.unix;
    };
  };
in
  tqm
