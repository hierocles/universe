{lib, ...}: let
  btrfsMountOptions = [
    "defaults"
    "compress-force=zstd"
    "noatime"
    "ssd"
  ];
in {
  # Source: https://github.com/nicdumz/nix-config/blob/main/nix/lib/disko/default.nix
  # TODO: there are ways to be smarter here and not repeat ourselves.

  # Note: swap size in G
  mkBtrfsDiskLayout = {
    swapsize,
    device,
  }: {
    disk = {
      main = {
        # When using disko-install, we will overwrite this value from the commandline
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              label = "boot";
              priority = 1;
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
                extraArgs = [
                  "-n"
                  "boot"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f" # Override existing partition
                  "-L"
                  "btrfs"
                ];
                subvolumes = {
                  "rootfs" = {
                    mountpoint = "/";
                  };
                  "home" = {
                    mountOptions = btrfsMountOptions;
                    mountpoint = "/home";
                  };
                  "nix" = {
                    mountOptions = btrfsMountOptions;
                    mountpoint = "/nix";
                  };
                  "/swap" = lib.mkIf (swapsize > 0) {
                    mountpoint = "/swap";
                    swap.swapfile.size = "${builtins.toString swapsize}G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # Create a striped mirror ZFS pool with multiple vdevs
  # Each vdev is a mirror of 2 disks, and multiple vdevs are striped together
  mkStripedMirrorZfsLayout = {
    vdevs, # List of vdev configurations, each containing 2 devices for mirroring
    poolName, # Name of the ZFS pool
    datasetMountpoints, # Mountpoints for datasets
    datasetOptions ? {}, # Options for datasets
  }: let
    # Flatten all devices from all vdevs into a single list for disk configuration
    allDevices = lib.flatten (lib.map (vdev: lib.attrValues vdev) vdevs);

    # Create disk configurations for all devices
    mkDiskConfig = device: {
      name = lib.getName device;
      value = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = poolName;
              };
            };
          };
        };
      };
    };

    # Build disk configurations for all devices
    diskConfigs = lib.listToAttrs (lib.map mkDiskConfig allDevices);

    # Create datasets configuration
    datasets =
      lib.mapAttrs' (name: mountpoint: {
        type = "zfs_fs";
        mountpoint = mountpoint;
      })
      datasetMountpoints;

    # Build vdev configuration for the pool
    # Each vdev should be a mirror of 2 devices
    vdevConfig =
      lib.map (vdev: {
        type = "mirror";
        disks = lib.attrValues vdev;
      })
      vdevs;
  in {
    disk = diskConfigs;
    zpool = {
      ${poolName} = {
        type = "zpool";
        vdevs = vdevConfig;
        options = datasetOptions;
        datasets = datasets;
      };
    };
  };
}
