{
  flake.modules.nixos.utilities = {profile, ...}: {
    # Services to start
    services = {
      upower.enable = true; # noctalia shell battery
      power-profiles-daemon.enable = true;
      tumbler.enable = true; # Image/video preview
      gnome.gnome-keyring.enable = true;
      smartd = {
        enable =
          if (profile == "vm") || (profile == "wsl")
          then false
          else true;
        autodetect = true;
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 256;
          };
        };
        extraConfig.pipewire-pulse."92-low-latency" = {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = "256/48000";
                pulse.default.req = "256/48000";
                pulse.max.req = "256/48000";
                pulse.min.quantum = "256/48000";
                pulse.max.quantum = "256/48000";
              };
            }
          ];
        };
      };
    };
  };
}
