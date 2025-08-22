{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  # Striped Mirror ZFS Pool Configuration (2x2)
  # Pool: 2 mirrored vdevs striped together
  # Vdev 1: sda + sdb (mirror) → 9.1TB usable
  # Vdev 2: sdc + sdd (mirror) → 9.1TB usable
  # Total: 18.2TB usable space across striped mirrors
  # Single mountpoint: /mnt/media for optimal media sharing performance
  # NVMe drive: 1.9TB BTRFS for NixOS system

  disko = {
    devices = let
      # Striped mirror configuration with 2 mirrored vdevs
      stripedMirrorConfig = mkStripedMirrorZfsLayout {
        vdevs = [
          # First mirror vdev (sda + sdb)
          {
            sda = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2YG8V7HD";
            sdb = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2TKWWHSD";
          }
          # Second mirror vdev (sdc + sdd)
          {
            sdc = "/dev/disk/by-id/ata-HUH721010ALE601_7JJ10PVC";
            sdd = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2YGE5SRD";
          }
        ];
        poolName = "media";
        mountpoint = "/mnt/media";
        datasetOptions = {
          # Disable automatic snapshots for media storage
          "com.sun:auto-snapshot" = "false";

          # Compression - lz4 is fast and provides good compression for media files
          compression = "lz4";

          # Disable access time updates for better performance
          atime = "off";

          # Use larger record sizes for better sequential I/O (ideal for media files)
          recordsize = "1M";

          # Optimize for sequential access patterns (media streaming)
          primarycache = "metadata";

          # Disable deduplication (not useful for media files and uses lots of RAM)
          dedup = "off";

          # Set reasonable sync behavior for better performance
          sync = "standard";

          # Optimize for large files (media content)
          logbias = "throughput";
        };
      };

      # NVMe drive for NixOS system
      nvmeConfig = mkBtrfsDiskLayout {
        swapsize = 32; # 32GB swap
        device = "/dev/disk/by-id/nvme-TEAM_TM8FP6002T_TPBF2312080030304554";
      };
    in {
      # Merge disk configurations with unique keys
      disk = stripedMirrorConfig.disk // nvmeConfig.disk;
      inherit (stripedMirrorConfig) zpool;
    };
  };
}
