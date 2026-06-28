{
  flake.modules.homeManager.i3 = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.i3.picom;
  in {
    options.homeManager.i3.picom = {
      enable = lib.mkEnableOption "Enable picom (blur and opacity)";
    };
    config = lib.mkIf cfg.enable {
      services.picom = {
        enable = true;
        backend = "glx"; # Uses GPU acceleration for smooth performance
        vSync = false;

        # Active/Inactive window transparency rules
        activeOpacity = 1.0; # Active windows remain perfectly crisp and opaque
        inactiveOpacity = 0.90; # Inactive windows dim down to 90% opacity

        # Global visual features
        shadow = true;
        shadowOpacity = 0.6;

        fade = true;
        fadeDelta = 5; # Smooth, snappy window open/close transitions

        # The frosted-glass blur configuration
        settings = {
          corner-radius = 0; # Smooth rounded window corners

          blur = {
            method = "dual_kawase";
            strength = 5;
            background = true;
          };

          # Fix for i3 tabbed/stacked layouts and standard transparent structures
          blur-background-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "class_g = 'Polybar'"
            "_GTK_FRAME_EXTENTS@:c"
          ];

          # Stop specific apps from dimming or blurring when unfocused
          focus-exclude = [
            "class_g = 'Cairo-clock'"
            "class_g = 'slop'" # Fixes flameshot/screenshot tools
          ];

          corner-radius-rules = [
            "30:class_g = 'Rofi'"
          ];

          rounded-corners-exclude = [
            "class_g = 'i3-frame'"
          ];
        };
      };
    };
  };
}
