{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: {
    options.custom.boot.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "systemd-boot, latest kernel, and plymouth";
    };

    config = lib.mkIf config.custom.boot.enable {
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        kernel.sysctl."vm.max_map_count" = 2147483642;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        plymouth = {
          enable = lib.mkDefault true;
          theme = "noctalia";
          themePackages = [
            inputs.noctalia-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          font = "${pkgs.inter}/share/fonts/truetype/InterVariable.ttf";
        };
      };
    };
  };
}
