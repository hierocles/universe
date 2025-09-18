{...}: _final: prev: {
  whisparr = prev.whisparr.overrideAttrs (old: rec {
    pname = "whisparr";
    version = "3.0.1.1280";
    src = prev.fetchurl {
      name = "${pname}-x86-linux-${version}.tar.gz";
      url = "https://whisparr.servarr.com/v1/update/eros/updatefile?runtime=netcore&version=${version}&arch=x86&os=linux";
      hash = "sha256-LChWbeq2MumS/ZbO/etsy/c8Ss2FDwkwDi4J683jQo8=";
    };
    passthru =
      old.passthru
      // {
        inherit version;
      };
  });
}
