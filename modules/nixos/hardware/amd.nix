{
  tags = ["amd"];
  platforms = ["linux"];
  module = {
    lib,
    pkgs,
    config,
    ...
  }: let
    cfg = config.custom.amd;
  in {
    options.custom.amd = {
      cpu.enable = lib.mkEnableOption "Extra settings for AMD CPU";
      gpu.enable = lib.mkEnableOption "AMD GPU driver";
    };

    config = lib.mkMerge [
      (lib.mkIf cfg.cpu.enable {
        boot = {
          initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
          kernelModules = ["kvm-amd"];
        };
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      })

      (lib.mkIf cfg.gpu.enable {
        systemd.tmpfiles.rules = ["L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"];
        services.xserver.videoDrivers = ["amdgpu"];
        nixpkgs.config.rocmSupport = true;
        hardware.graphics.enable = lib.mkDefault true;
      })
    ];
  };
}
