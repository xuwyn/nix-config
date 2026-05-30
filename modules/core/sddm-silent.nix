{
  inputs,
  username,
  ...
}: {
  imports = [inputs.silentSDDM.nixosModules.default];
  # workaround sddm/nvidia race condition
  systemd.services.sddm = {
    # hard-coded delay
    preStart = ''
      sleep 3
    '';
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
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
