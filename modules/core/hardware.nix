{pkgs, ...}: {
  hardware = {
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    logitech.wireless.enable = false;
    logitech.wireless.enableGraphical = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    i2c.enable = true;
  };
  # set hardware clock to local time (not needed)
  time.hardwareClockInLocalTime = false;
  # monitor brightness
  services.udev.packages = [pkgs.ddcutil];
}
