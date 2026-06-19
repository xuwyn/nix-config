{
  inputs,
  host,
  pkgs,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) displayManager qylockTheme;
  qylockSDDMEnable = displayManager == "qylock";
in {
  imports = [inputs.qylock.nixosModules.default];
  environment.systemPackages = with pkgs; [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

  # NVIDIA shenanigan workarounds
  environment.sessionVariables = {
    # Tells GStreamer to fallback to x11 for video frames
    # GST_GL_WINDOW = "x11";
    # Or disable QT hardware acceleration
    QT_DISABLE_HW_TEXTURES_CONVERSION = "1";
  };

  #See https://github.com/Darkkal44/qylock/tree/main/themes
  programs.qylock = {
    enable = true;
    theme = qylockTheme;
    sddm.enable = qylockSDDMEnable;
    quickshell.enable = true;

    # Optional per-theme tweaks (replaces the interactive prompts):
    themeOptions = {
      terraria.backgroundMode = "time"; # time | random | static
      Genshin.backgroundMode = "time";
      clockwork.orbital = {
        themeMode = "dark";
        enableWindup = true;
      };
      osu.gameMode = "menu"; # menu | game
    };
  };
}
