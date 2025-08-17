{
  lib,
  pkgs,
  config,
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
        datasetMountpoints = {
          "media" = "/mnt/media";
        };
        datasetOptions = {
          "media" = {
            "com.sun:auto-snapshot" = "false";
          };
        };
      };

      # NVMe drive for NixOS system
      nvmeConfig = mkBtrfsDiskLayout {
        swapsize = 32; # 32GB swap
        device = "/dev/disk/by-id/nvme-TEAM_TM8FP6002T_TPBF2312080030304554";
      };
    in {
      disk = stripedMirrorConfig.disk // nvmeConfig.disk;
      zpool = stripedMirrorConfig.zpool;
    };
  };
}
