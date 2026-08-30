{
  modules.nixos.services = {
    config,
    lib,
    inputs,
    pkgs,
    ...
  }: let
    cfg = config.nixos.services.atticd;
    unstableNixpkgs = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    options.nixos.services.atticd = {
      enable = lib.mkEnableOption "Enable Attic cache server";
      device = lib.mkOption {
        type = lib.types.str;
        description = "Disk UUID for atticd storage";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port atticd listens on (internal, behind nginx)";
      };
      tailscaleDomain = lib.mkOption {
        type = lib.types.str;
        description = "Tailnet MagicDNS FQDN, e.g. hostname.*-tailnet.ts.net";
      };
      lanDomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "LAN-only hostname via mDNS. Null disables the LAN vhost";
      };
      lanInterface = lib.mkOption {
        type = lib.types.str;
        default = "wlan0";
        description = "Network interface name for the LAN-facing vhost";
      };
      lanCertValidityDays = lib.mkOption {
        type = lib.types.int;
        default = 60;
        description = "LAN self-signed cert rotation period in days";
      };
    };

    config = lib.mkIf cfg.enable {
      # attic-server
      environment.systemPackages = [unstableNixpkgs.attic-server];
      sops.secrets.atticd_env = {};
      services.atticd = {
        enable = true;
        package = unstableNixpkgs.attic-server;
        environmentFile = config.sops.secrets.atticd_env.path;
        settings = {
          listen = "127.0.0.1:${toString cfg.port}";
          database.url = "postgres://atticd@localhost/atticd?host=/run/postgresql";
          storage = {
            type = "local";
            path = "/mnt/atticd/storage";
          };
          compression = {type = "zstd";};
          chunking = {
            nar-size-threshold = 64 * 1024; # 64 KiB
            min-size = 16 * 1024; # 16 KiB
            avg-size = 64 * 1024; # 64 KiB
            max-size = 256 * 1024; # 256 KiB
          };
        };
      };
      # Mount atticd storage
      fileSystems."/mnt/atticd" = {
        inherit (cfg) device;
        fsType = "ext4";
        options = ["noatime"];
      };

      # postgresl only stores metadata
      services.postgresql = {
        enable = true;
        ensureDatabases = ["atticd"];
        ensureUsers = [
          {
            name = "atticd";
            ensureDBOwnership = true;
          }
        ];
      };
      systemd.services.atticd = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
      };

      # generate tailscale certs
      systemd.services.tailscale-cert-renew = {
        after = ["tailscaled.service"];
        wants = ["tailscaled.service"];
        wantedBy = ["multi-user.target"];
        before = ["nginx.service"];
        # restart if tailscaled is loaded but not connected to server yet
        serviceConfig = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        # prevent rapid restart if tailscale server is inaccessible
        startLimitIntervalSec = 300;
        startLimitBurst = 10;
        script = ''
          ${unstableNixpkgs.tailscale}/bin/tailscale cert \
            --cert-file /var/lib/atticd-certs/tailscale.crt \
            --key-file /var/lib/atticd-certs/tailscale.key \
            ${cfg.tailscaleDomain}
          chown root:${config.services.nginx.group} /var/lib/atticd-certs/tailscale.key
          chmod 640 /var/lib/atticd-certs/tailscale.key
        '';
      };
      systemd.timers.tailscale-cert-renew = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };

      # generate self-signed certs for LAN
      systemd.services.lan-cert-renew = lib.mkIf (cfg.lanDomain != null) {
        wantedBy = ["multi-user.target"];
        before = ["nginx.service"];
        serviceConfig.Type = "oneshot";
        script = ''
          if [ -f /var/lib/atticd-certs/lan.crt ] && \
             ${unstableNixpkgs.openssl}/bin/openssl x509 -in /var/lib/atticd-certs/lan.crt -checkend 0 -noout; then
            exit 0
          fi
          ${unstableNixpkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -nodes \
            -keyout /var/lib/atticd-certs/lan.key \
            -out /var/lib/atticd-certs/lan.crt \
            -days ${toString cfg.lanCertValidityDays} \
            -subj "/CN=${cfg.lanDomain}" \
            -addext "subjectAltName=DNS:${cfg.lanDomain}"
          chown root:${config.services.nginx.group} /var/lib/atticd-certs/lan.key
          chmod 640 /var/lib/atticd-certs/lan.key
        '';
      };
      systemd.timers.lan-cert-renew = lib.mkIf (cfg.lanDomain != null) {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };

      # fix permission
      systemd.tmpfiles.rules = [
        "d /var/lib/atticd-certs 0750 root ${config.services.nginx.group} -"
        "d /mnt/atticd/storage 0750 atticd atticd -"
      ];

      # reload nginx if cert changed
      systemd.services.nginx.reloadTriggers = [
        "/var/lib/atticd-certs/tailscale.crt"
        "/var/lib/atticd-certs/lan.crt"
      ];

      # setup nginx for tailnet and LAN
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
        virtualHosts =
          {
            ${cfg.tailscaleDomain} = {
              onlySSL = true;
              sslCertificate = "/var/lib/atticd-certs/tailscale.crt";
              sslCertificateKey = "/var/lib/atticd-certs/tailscale.key";
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString cfg.port}";
                # remove payload size limit
                extraConfig = ''
                  client_max_body_size 0;
                '';
              };
            };
          }
          // lib.optionalAttrs (cfg.lanDomain != null) {
            ${cfg.lanDomain} = {
              onlySSL = true;
              sslCertificate = "/var/lib/atticd-certs/lan.crt";
              sslCertificateKey = "/var/lib/atticd-certs/lan.key";
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString cfg.port}";
                # remove payload size limit
                extraConfig = ''
                  client_max_body_size 0;
                '';
              };
            };
          };
      };

      networking.firewall.interfaces =
        {
          "tailscale0".allowedTCPPorts = [443];
        }
        // lib.optionalAttrs (cfg.lanDomain != null) {
          ${cfg.lanInterface}.allowedTCPPorts = [443];
        };
    };
  };
}
