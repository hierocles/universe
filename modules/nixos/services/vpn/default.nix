{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.vpn;
in {
  options.${namespace}.services.vpn = with types; {
    enable = mkBoolOpt false "Whether or not to enable VPN confinement for services.";

    namespaceName = mkOption {
      type = str;
      default = "torrent";
      description = "Name of the VPN namespace (limited to 7 characters).";
    };

    wireguardConfigFile = mkOption {
      type = path;
      description = "Path to the WireGuard configuration file.";
      example = "/etc/wireguard/wg0.conf";
    };

    accessibleFrom = mkOption {
      type = listOf str;
      default = ["192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12"];
      description = "List of IP ranges that can access services in the VPN namespace.";
      example = ["192.168.1.0/24" "10.0.0.0/8"];
    };

    portMappings = mkOption {
      type = listOf (submodule {
        options = {
          from = mkOption {
            type = port;
            description = "Port on the host to map.";
          };
          to = mkOption {
            type = port;
            description = "Port in the VPN namespace.";
          };
          protocol = mkOption {
            type = enum ["tcp" "udp" "both"];
            default = "tcp";
            description = "Transport protocol for the mapping.";
          };
        };
      });
      default = [];
      description = "Port mappings between host and VPN namespace.";
    };

    openVPNPorts = mkOption {
      type = listOf (submodule {
        options = {
          port = mkOption {
            type = port;
            description = "Port to open on the VPN interface.";
          };
          protocol = mkOption {
            type = enum ["tcp" "udp" "both"];
            default = "tcp";
            description = "Transport protocol.";
          };
        };
      });
      default = [];
      description = "Ports to open on the VPN interface.";
    };

    dnsServers = mkOption {
      type = listOf str;
      default = ["1.1.1.1" "1.0.0.1"];
      description = "DNS servers to use within the VPN namespace.";
    };
  };

  config = mkIf cfg.enable {
    # Configure VPN namespace using VPN-Confinement
    vpnNamespaces.${cfg.namespaceName} = {
      enable = true;
      inherit (cfg) wireguardConfigFile accessibleFrom portMappings openVPNPorts;
    };

    # Ensure proper networking setup and firewall rules for port mappings
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts =
          map (mapping: mapping.from)
          (filter (mapping: mapping.protocol == "tcp" || mapping.protocol == "both") cfg.portMappings);

        allowedUDPPorts =
          map (mapping: mapping.from)
          (filter (mapping: mapping.protocol == "udp" || mapping.protocol == "both") cfg.portMappings);
      };
    };
  };
}
