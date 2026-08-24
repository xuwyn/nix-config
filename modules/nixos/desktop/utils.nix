{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.utils;
  in {
    options.nixos.desktop.utils = {
      enable = lib.mkEnableOption "Enable Extra Utils for Desktop (upower, fcitx5, pipwire, etc. )";
    };
    config = lib.mkIf cfg.enable {
      # Keyboard input for other languages
      i18n.inputMethod = {
        enable = true;
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
        seahorse.enable = true;
        localsend.enable = true;
        dconf.enable = true;
      };

      # security features only relevant on desktop
      security = {
        rtkit.enable = true;
        polkit = {
          enable = true;
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

      # Services to start
      services = {
        xserver = {
          enable = true;
          excludePackages = [pkgs.xterm];
        };
        upower.enable = true; # noctalia shell battery
        power-profiles-daemon.enable = true;
        blueman.enable = true; # Bluetooth Tray
        gvfs.enable = true; # GUI for Mounting Drives
        tumbler.enable = true; # Image/video preview
        gnome.gnome-keyring.enable = true;
        smartd = {
          enable =
            if config ? nixos.drivers.vm.enable
            then !(config.nixos.drivers.vm.enable)
            else true;
          autodetect = true;
        };
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };
      };
    };
  };
}
