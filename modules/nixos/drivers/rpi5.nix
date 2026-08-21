{
  modules.nixos.drivers = {
    lib,
    config,
    inputs,
    ...
  }:
    with lib; let
      cfg = config.nixos.drivers.rpi5;
    in {
      options.nixos.drivers.rpi5 = {
        enable = mkEnableOption "Enable rpi5";
      };
      imports = [inputs.nixos-hardware.nixosModules.raspberry-pi-5];
      config = mkIf cfg.enable {
        nix.settings.system-features = ["nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a"];
        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
          };
          "/boot/firmware" = {
            device = "/dev/disk/by-label/FIRMWARE";
            fsType = "vfat";
          };
        };
        # Read: https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi
        hardware.raspberry-pi = {
          firmware = {
            enable = true;
            uboot.enable = true;
          };
          configtxt.settings = {};
        };
      };
    };
}
