{
  inputs,
  host,
  username,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) displayManager;
  qylockEnable = displayManager == "qylock";
in {
  imports =
    if qylockEnable
    then []
    else [inputs.silentSDDM.nixosModules.default];

  environment.systemPackages = [pkgs.bibata-cursors];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = lib.mkForce false; # nvidia shenanigan

    # Enable custom cursor
    setupScript = ''
      ${pkgs.xrdb}/bin/xrdb -merge - <<EOF
      Xcursor.theme: Bibata-Modern-Ice
      Xcursor.size: 24
      EOF
    '';
  };

  programs =
    if displayManager == "silent"
    then {
      silentSDDM = {
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
    else {};
}
