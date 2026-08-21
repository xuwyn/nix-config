{
  modules.nixos.hardware = {pkgs, ...}: {
    hardware = {
      sane = {
        enable = true;
        extraBackends = [pkgs.sane-airscan];
        disabledDefaultBackends = ["escl"];
      };
      logitech.wireless.enable = false;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      enableRedistributableFirmware = true;
      keyboard.qmk.enable = true;
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
      i2c.enable = true;
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50; # % of RAM
      priority = 100; # higher than disk swap
    };

    systemd.oomd = {
      enable = true;
      enableSystemSlice = true;
      enableRootSlice = true;
      enableUserSlices = true;
    };

    services = {
      libinput.enable = true; # Input Handling
      fstrim.enable = true; # SSD Optimizer
    };

    environment.systemPackages = with pkgs; [
      mesa-demos # glxinfo, eglinfo
      lm_sensors # sensors
      lshw # hardware report
      pciutils # lspci
      usbutils # lsusb
      brightnessctl # laptop backlight
      ddcutil # monitor brightness
      power-profiles-daemon # power management
      upower # System daemon for battery tracking
      v4l-utils # handles kernel-level webcam/OBS
      smartmontools # smartctl for drive health
    ];

    # set hardware clock to local time (not needed)
    time.hardwareClockInLocalTime = false;
    # monitor brightness
    services.udev.packages = [pkgs.ddcutil];
  };
}
