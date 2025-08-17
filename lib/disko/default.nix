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
    vdevs, # List of vdev configurations, each containing device mappings (diskName -> devicePath)
    poolName, # Name of the ZFS pool
    mountpoint, # Main mountpoint for the pool
    datasetOptions ? {}, # Options for the pool
  }: let
    # Create disk configurations for all devices
    mkDiskConfig = vdev:
      lib.mapAttrs' (diskName: devicePath: {
        name = diskName;
        value = {
          device = devicePath;
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
      })
      vdev;

    # Build disk configurations for all devices from all vdevs
    diskConfigs = lib.foldl' (acc: vdev: acc // (mkDiskConfig vdev)) {} vdevs;

    # Build the correct ZFS pool topology for disko
    # Format: "mirror disk1 disk2 mirror disk3 disk4" for striped mirrors
    poolTopology = lib.concatStringsSep " " (
      lib.map (
        vdev:
          "mirror " + (lib.concatStringsSep " " (lib.attrNames vdev))
      )
      vdevs
    );
  in {
    disk = diskConfigs;
    zpool = {
      ${poolName} = {
        type = "zpool";
        mode = poolTopology;
        inherit mountpoint;
        options = datasetOptions;
      };
    };
  };
}
