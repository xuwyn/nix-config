{
  pkgs,
  config,
  ...
}: {
  boot = {
    # an attempt at loading nvidia driver before sddm
    initrd.kernelModules = [
      "nvidia"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia_drm.fbdev=1"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "v4l2loopback"
      "i2c-dev"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
      config.boot.kernelPackages.nvidia_x11
    ];
    kernel.sysctl = {"vm.max_map_count" = 2147483642;};
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = true;
  };
}
