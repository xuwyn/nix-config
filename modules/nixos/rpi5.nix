{
  modules.nixos.rpi5 = {
    lib,
    config,
    inputs,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.raspberry-pi-5
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
    boot.initrd.systemd.enable = lib.mkForce false;
    boot.supportedFilesystems.zfs = lib.mkForce false;
    sdImage.firmwareSize = 512; # MB
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
    nix.settings.system-features = ["nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a"];
    # Read: https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi
    hardware.raspberry-pi = {
      firmware = {
        enable = true;
        uboot.enable = true;
      };
      configtxt.settings = {
        all = {
          dtparam = ["audio=on" "i2c_arm=on"];
          dtoverlay = ["vc4-kms-v3d"];
          arm_boost = lib.mkForce null;
        };
      };
    };
  };
}
