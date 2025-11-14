{
  lib,
  buildGoModule,
  stdenv,
  fetchFromGitHub,
  pnpm_9,
  nodejs,
  ...
}: let
  # Build the frontend separately using stdenv
  frontend = stdenv.mkDerivation rec {
    pname = "qui-frontend";
    version = "1.7.0";

    src = fetchFromGitHub {
      owner = "autobrr";
      repo = "qui";
      rev = "v${version}";
      hash = "sha256-CbPdngskDCAAhmsj5DPdnviZSWM0bO13Pbe7wRwaNaw=";
    };

    sourceRoot = "${src.name}/web";

    # Use pnpm.fetchDeps for pnpm projects
    pnpmDeps = pnpm_9.fetchDeps {
      pname = "qui-frontend-deps";
      inherit version src sourceRoot;
      hash = "sha256-WKoWts+/TGcGy/rFEJN3Qn/vq+gj+Mq+VcTYowEyvus=";
      fetcherVersion = 2;
    };

    nativeBuildInputs = [
      nodejs
      pnpm_9.configHook
    ];

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };

  # Build the main Go application with Go 1.25
  qui = buildGoModule rec {
    pname = "qui";
    version = "1.7.0";

    src = fetchFromGitHub {
      owner = "autobrr";
      repo = "qui";
      rev = "v${version}";
      hash = "sha256-CbPdngskDCAAhmsj5DPdnviZSWM0bO13Pbe7wRwaNaw=";
    };

    vendorHash = "sha256-rmUEFX8UzxEN7XaJ8Zj+kj3z1pwLkq3FTYzbPWnifW0=";

    # Disable tests as they may require network or filesystem access
    doCheck = false;

    # Copy the built frontend into the source tree before building
    preBuild = ''
      mkdir -p internal/http/dist
      cp -r ${frontend}/* internal/http/dist/
    '';

    ldflags = [
      "-s"
      "-w"
      "-X github.com/autobrr/qui/internal/buildinfo.Version=${version}"
      "-X github.com/autobrr/qui/internal/buildinfo.Date=1970-01-01T00:00:00Z"
    ];

    meta = with lib; {
      description = "A fast, modern web interface for qBittorrent with multi-instance management";
      homepage = "https://github.com/autobrr/qui";
      downloadPage = "https://github.com/autobrr/qui/releases";
      license = licenses.gpl3Only;
      maintainers = [];
      mainProgram = "qui";
      platforms = platforms.unix;
    };
  };
in
  qui
