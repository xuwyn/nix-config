{
  inputs,
  username,
  lib,
  ...
}: {
  imports = [inputs.silentSDDM.nixosModules.default];
  # workaround sddm/nvidia race condition
  systemd.services.display-manager = {
    after = ["graphics.target"];
    wants = ["graphics.target"];

    # Allow up to 3 start attempts within 30 seconds
    startLimitIntervalSec = 30;
    startLimitBurst = 3;

    serviceConfig = {
      # Restart if the service crashes, exits with an error, or times out
      Restart = lib.mkForce "on-failure";

      # Wait 2 seconds before attempting the restart (gives Nvidia time to breathe)
      RestartSec = lib.mkForce "2s";
    };
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  programs.silentSDDM = {
    enable = true;
    theme = "silvia";
    backgrounds = {
      cyTus = ../../wallpapers/cyTus.mp4;
      frame-1 = ../../wallpapers/frame-1.png;
    };
    profileIcons = {
      ${username} = ../home/hyprland/face.jpg;
    };
    settings = {
      "General" = {
        scale = 1.0;
        enable-animations = true;
        animated-background-placeholder = "frame-1.png";
        background-fill-mode = "fill";
      };
      "LockScreen" = {
        background = "cyTus.mp4";
        saturation = 0;
      };
      "LoginScreen" = {
        background = "cyTus.mp4";
      };
    };
  };
}
