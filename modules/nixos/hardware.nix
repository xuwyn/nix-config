{
  modules.nixos.hardware = {pkgs, ...}: {
    hardware = {
      sane = {
        enable = true;
        extraBackends = [pkgs.sane-airscan];
        disabledDefaultBackends = ["escl"];
      };
      logitech.wireless.enable = false;
      logitech.wireless.enableGraphical = false;
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

    environment.systemPackages = with pkgs; [
      brightnessctl # Needs hardware permissions to alter laptop backlight
      ddcutil # Needs direct access to monitor I2C buses for brightness
      power-profiles-daemon # System-level power management daemon
      upower # System daemon for battery tracking
      v4l-utils # Video4Linux utils; handles kernel-level webcam/OBS loops
    ];

    # set hardware clock to local time (not needed)
    time.hardwareClockInLocalTime = false;
    # monitor brightness
    services.udev.packages = [pkgs.ddcutil];
  };
}
