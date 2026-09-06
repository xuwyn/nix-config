{
  modules.nixos.zram = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.zram;
  in {
    options.nixos.zram = {
      tmpMaxSize = lib.mkOption {
        type = lib.types.str;
        default = "2048";
        description = "Size spec for the /tmp zram-backed filesystem";
      };
    };
    config = {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50; # % of RAM
        priority = 100; # higher than disk swap
      };

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
