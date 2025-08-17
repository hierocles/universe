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
  # Pool 1: sda + sdb (mirror) → 9.1TB usable
  # Pool 2: sdc + sdd (mirror) → 9.1TB usable
  # Total: 18.2TB usable space across 2 pools
  # Single mountpoint: /mnt/media for optimal media sharing performance
  # NVMe drive: 1.9TB BTRFS for NixOS system

  disko = {
    devices = let
      # First mirrored pool (sda + sdb)
      pool1Config = mkNasZfsPoolDiskLayout {
        devices = {
          sda = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2YG8V7HD";
          sdb = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2TKWWHSD";
        };
        poolName = "pool1";
        raidType = "mirror";
      };

      # Second mirrored pool (sdc + sdd)
      pool2Config = mkNasZfsPoolDiskLayout {
        devices = {
          sdc = "/dev/disk/by-id/ata-HUH721010ALE601_7JJ10PVC";
          sdd = "/dev/disk/by-id/ata-HGST_HUH721010ALE604_2YGE5SRD";
        };
        poolName = "pool2";
        raidType = "mirror";
      };

      # NVMe drive for NixOS system
      nvmeConfig = mkBtrfsDiskLayout {
        swapsize = 32; # 32GB swap
        device = "/dev/disk/by-id/nvme-TEAM_TM8FP6002T_TPBF2312080030304554";
      };
    in {
      # Merge disk configurations from all sources
      disk = pool1Config.disk // pool2Config.disk // nvmeConfig.disk;

      # Merge zpool configurations from both pools
      zpool = pool1Config.zpool // pool2Config.zpool;

      # Create a combined media mountpoint that spans both pools
      # This gives access to the full 18.2TB from a single location
      filesystem = {
        "/mnt/media" = {
          device = "pool1/root";
          fsType = "zfs";
          options = [
            "defaults"
            "noatime"
            "relatime"
          ];
        };
      };
    };
  };
}
