{
  platforms = ["linux"];
  module = {
    config,
    lib,
    inputs,
    system,
    ...
  }: let
    cfg = config.custom.zram;
  in {
    options.custom.zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "zram swap, zram-backed /tmp, and systemd-oomd";
      };
      tmpMaxSize = lib.mkOption {
        type = lib.types.str;
        default = "2048";
        description = "Size spec for the /tmp zram-backed filesystem";
      };
    };

    config = lib.mkIf cfg.enable {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50; # % of RAM
        priority = 100; # higher than disk swap
      };

      # for hydra cache hit
      services.zram-generator.package = inputs.nixpkgs.legacyPackages.${system}.zram-generator;

      # high swappiness is ideal for ram swap
      boot.kernel.sysctl."vm.swappiness" = 180;

      # use ram for /tmp
      boot.tmp = {
        useZram = lib.mkDefault true;
        zramSettings = {
          zram-size = cfg.tmpMaxSize;
          compression-algorithm = "zstd";
        };
      };

      # kill proc to free memory
      systemd.oomd = {
        enable = lib.mkDefault true;
        enableSystemSlice = true;
        enableRootSlice = true;
        enableUserSlices = true;
      };
    };
  };
}
