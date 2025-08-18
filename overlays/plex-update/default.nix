{channels, ...}: final: prev: {
  plex = prev.plex.overrideAttrs (oldAttrs: {
    version = "1.42.1.10060-4e8b05daf";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/1.42.1.10060-4e8b05daf/debian/plexmediaserver_1.42.1.10060-4e8b05daf_amd64.deb";
      sha256 = "OoItvG0IpgUKlZ0JmzDc2WqMtyZrlNCF7MCnUKqBl/Q=";
    };
  });
}
