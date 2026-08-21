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
        boot.initrd.systemd.enable = lib.mkForce false;
        # boot.kernelParams = ["video=efifb:off" "fbcon=rotate:0" "video=1920x1080-32"];
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
            # uboot.enable = true;
          };
          # configtxt.settings = {
          #   all = {
          #     dtparam = [
          #       "audio=on"
          #       "i2c_arm=on"
          #     ];
          #     dtoverlay = [
          #       "vc4-kms-v3d"
          #       # "disable-bt"
          #     ];
          #     arm_boost = lib.mkForce null;
          #   };
          # };
        };
      };
    };
}
