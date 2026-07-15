{
  modules.nixos.drivers = {
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.nixos.drivers.amdcpu;
    in {
      options.nixos.drivers.amdcpu = {
        enable = mkEnableOption "Extra Settings for AMD CPU";
      };

      config = mkIf cfg.enable {
        boot = {
          initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
          kernelModules = ["kvm-amd"];
        };
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
}
