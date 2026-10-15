{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    lib,
    ...
  }: {
    # Keyboard input for other languages
    i18n.inputMethod = {
      enable = lib.mkDefault true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-bamboo
        ];
      };
    };

    # Extra software
    programs = {
      localsend.enable = lib.mkDefault true;
      dconf.enable = lib.mkDefault true;
    };

    # security features only relevant on desktop
    security = {
      rtkit.enable = lib.mkDefault true;
      polkit = {
        enable = lib.mkDefault true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if ( subject.isInGroup("users") && (
             action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
             action.id == "org.freedesktop.login1.power-off" ||
             action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            ))
            { return polkit.Result.YES; }
          })
        '';
      };
    };

    environment.systemPackages = with pkgs; [
      brightnessctl # laptop backlight
      ddcutil # monitor brightness
    ];

    hardware.bluetooth.enable = lib.mkDefault true;

    # Services to start
    services = {
      udev.packages = [pkgs.ddcutil];
      xserver = {
        enable = lib.mkDefault true;
        excludePackages = [pkgs.xterm];
      };
      upower.enable = lib.mkDefault true; # battery
      power-profiles-daemon.enable = lib.mkDefault true;
      blueman.enable = lib.mkDefault true; # Bluetooth Tray
      gvfs.enable = lib.mkDefault true; # GUI for Mounting Drives
      tumbler.enable = lib.mkDefault true; # Image/video preview
      gnome.gnome-keyring.enable = lib.mkDefault true;
      smartd = {
        enable = lib.mkDefault true;
        autodetect = true;
      };
      pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        alsa.support32Bit = true;
        pulse.enable = lib.mkDefault true;
        jack.enable = lib.mkDefault true;
      };
    };
  };
}
