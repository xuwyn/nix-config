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
    imports = [inputs.stylix.nixosModules.stylix];

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
        plymouth.enable = lib.mkDefault true;
      };

      # stylix just for plymouth
      stylix = {
        enable = config.boot.plymouth.enable;
        autoEnable = false;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        targets.plymouth.enable = true;
      };
    };
  };
}
