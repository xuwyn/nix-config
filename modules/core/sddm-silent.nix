{
  inputs,
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.silentSDDM.nixosModules.default];
  # workaround sddm/nvidia race condition
  # systemd.services.restart-dm-on-boot = {
  #   description = "Delayed restart of display manager on boot";
  #   wantedBy = ["multi-user.target"];
  #   after = ["display-manager.service"];
  #
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 10 && systemctl restart display-manager'";
  #   };
  # };

  # systemd.services.display-manager = {
  #   # after = ["dev-dri-card1.device"];
  #   # wants = ["dev-dri-card1.device"];
  #
  #   # Allow up to 3 start attempts within 30 seconds
  #   startLimitIntervalSec = 30;
  #   startLimitBurst = 3;
  #
  #   serviceConfig = {
  #     # forced delay
  #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
  #     # timeout duration
  #     TimeoutStartSec = "10s";
  #     # Restart if the service crashes, exits with an error, or times out
  #     Restart = "always";
  #     # Wait 2 seconds before attempting the restart (gives Nvidia time to breathe)
  #     RestartSec = lib.mkForce "2s";
  #   };
  # };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = lib.mkForce false;
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
