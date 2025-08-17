{
  options,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.nginx;
in {
  options.${namespace}.services.nginx = with types; {
    enable = mkBoolOpt false "Whether or not to enable nginx reverse proxy for *arr services.";

    domain = mkOption {
      type = str;
      default = "media.local";
      description = "Base domain for *arr services.";
    };

    ssl = mkBoolOpt false "Whether to enable SSL/TLS for nginx virtual hosts.";

    acme = mkBoolOpt false "Whether to enable ACME (Let's Encrypt) for SSL certificates.";

    services = mkOption {
      type = attrsOf (submodule {
        options = {
          enable = mkBoolOpt true "Whether to enable this service's virtual host.";
          subdomain = mkOption {
            type = str;
            description = "Subdomain for this service.";
          };
          port = mkOption {
            type = port;
            description = "Local port for this service.";
          };
          extraLocationConfig = mkOption {
            type = lines;
            default = "";
            description = "Extra nginx location configuration.";
          };
        };
      });
      default = {};
      description = "Services to proxy through nginx.";
    };

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Extra nginx configuration.";
    };

    openFirewall = mkBoolOpt true "Whether to open firewall ports for nginx.";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = mkIf cfg.ssl true;

      # Common proxy headers for *arr services
      commonHttpConfig = ''
        # Set real IP for behind reverse proxy setups
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;

        # Increase buffer sizes for large headers (useful for some *arr services)
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;

        ${cfg.extraConfig}
      '';

      virtualHosts = mapAttrs (_: serviceConfig:
        mkIf serviceConfig.enable {
          serverName = "${serviceConfig.subdomain}.${cfg.domain}";
          forceSSL = cfg.ssl;
          enableACME = cfg.acme;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString serviceConfig.port}";
            proxyWebsockets = true;
            extraConfig = ''
              # Standard proxy headers
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $server_name;

              # Disable buffering for real-time features
              proxy_buffering off;

              ${serviceConfig.extraLocationConfig}
            '';
          };
        })
      cfg.services;
    };

    # Auto-configure *arr services if they're enabled
    ${namespace}.services.nginx.services = {
      sonarr = mkIf config.${namespace}.services.sonarr.enable {
        subdomain = "sonarr";
        inherit (config.${namespace}.services.sonarr) port;
      };

      radarr = mkIf config.${namespace}.services.radarr.enable {
        subdomain = "radarr";
        inherit (config.${namespace}.services.radarr) port;
      };

      prowlarr = mkIf config.${namespace}.services.prowlarr.enable {
        subdomain = "prowlarr";
        inherit (config.${namespace}.services.prowlarr) port;
      };

      bazarr = mkIf config.${namespace}.services.bazarr.enable {
        subdomain = "bazarr";
        inherit (config.${namespace}.services.bazarr) port;
      };

      jellyseerr = mkIf config.${namespace}.services.jellyseerr.enable {
        subdomain = "requests";
        inherit (config.${namespace}.services.jellyseerr) port;
      };

      plex = mkIf config.${namespace}.services.plex.enable {
        subdomain = "plex";
        inherit (config.${namespace}.services.plex) port;
      };

      jellyfin = mkIf config.${namespace}.services.jellyfin.enable {
        subdomain = "jellyfin";
        inherit (config.${namespace}.services.jellyfin) port;
      };

      transmission = mkIf config.${namespace}.services.torrent.enable {
        subdomain = "torrent";
        inherit (config.${namespace}.services.torrent) port;
        extraLocationConfig = ''
          # Special headers for Transmission RPC
          proxy_set_header X-Transmission-Session-Id $http_x_transmission_session_id;
        '';
      };
    };

    # Open firewall ports
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall (
      [80] # HTTP
      ++ lib.optionals cfg.ssl [443] # HTTPS
    );

    # ACME configuration for SSL
    security.acme = mkIf cfg.acme {
      acceptTerms = true;
      defaults.email = mkDefault "admin@${cfg.domain}";
    };
  };
}
