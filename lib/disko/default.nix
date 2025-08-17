{lib, ...}: let
  btrfsMountOptions = [
    "defaults"
    "compress-force=zstd"
    "noatime"
    "ssd"
  ];
  zfsMountOptions = [
    "defaults"
    "compress=zstd"
    "noatime"
    "relatime"
    "xattr=sa"
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

  mkNasZfsPoolDiskLayout = {
    devices,
    poolName,
    raidType ? "raidz1",
  }: let
    # Convert devices attrset to list for easier processing
    deviceList = lib.attrValues devices;
    deviceNames = lib.attrNames devices;

    # Create disk configurations dynamically
    mkDiskConfig = deviceName: device: {
      "${deviceName}" = {
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
    diskConfigs = lib.mapAttrs' mkDiskConfig devices;
  in {
    disk = diskConfigs;
    zpool = {
      "${poolName}" = {
        type = "zpool";
        mode = raidType;
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          mountpoint = "none";
        };
        datasets = {
          # Root dataset for the pool
          "root" = {
            type = "zfs_fs";
            mountpoint = "/mnt/${poolName}";
            options =
              {
                mountpoint = "/mnt/${poolName}";
              }
              // zfsMountOptions;
          };
        };
      };
    };
  };
}
