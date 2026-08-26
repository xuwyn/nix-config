{
  modules.nixos.services = {
    config,
    lib,
    inputs,
    pkgs,
    ...
  }: let
    cfg = config.nixos.services.atticd;
    atticdPkgs = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.attic-server;
  in {
    options.nixos.services.atticd = {
      enable = lib.mkEnableOption "Enable Attic cache server";
      device = lib.mkOption {
        type = lib.types.str;
        description = "Disk UUID for postgresql database";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port atticd listens on";
      };
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [atticdPkgs];
      fileSystems."/var/lib/postgresql" = {
        inherit (cfg) device;
        fsType = "ext4";
        options = ["noatime"];
      };
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
      sops.secrets.atticd_env = {};
      services.atticd = {
        enable = true;
        package = atticdPkgs;
        environmentFile = config.sops.secrets.atticd_env.path;
        settings = {
          listen = "[::]:${toString cfg.port}";
          database.url = "postgres://atticd@localhost/atticd?host=/run/postgresql";
          storage = {
            type = "local";
            path = "/var/lib/atticd/storage";
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
      systemd.services.atticd = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
      };
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [cfg.port];
    };
  };
}
