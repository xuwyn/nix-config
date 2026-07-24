{
  config,
  lib,
  ...
}: let
  inherit (config.homeManager.desktop) browser terminal bar;
  barBinds =
    if bar == "noctalia"
    then (import ../noctalia/_binds.nix) {inherit config;}
    else if bar == "dms"
    then (import ../dms/_binds.nix) {inherit config;}
    else [];
  toNiriKey = key: let
    parts = lib.splitString " + " key;
    rename = p:
      if p == "SUPER"
      then "Mod"
      else if p == "ALT"
      then "Alt"
      else if p == "SHIFT"
      then "Shift"
      else if p == "CTRL" || p == "CONTROL"
      then "Ctrl"
      else if p == "TAB"
      then "Tab"
      else if p == "DELETE"
      then "Delete"
      else p;
  in
    lib.concatStringsSep "+" (map rename parts);
in {
  wayland.windowManager.niri.settings = {
    recent-windows = {
      binds = {
        "Alt+Tab" = {next-window._props = {scope = "output";};};
      };
    };
    binds =
      {
        # TOGGLE OVERVIEW
        "Mod+Tab" = {
          _props = {repeat = false;};
          toggle-overview = [];
        };

        # MOVE WINDOW INTO NEIGHBOURING COLUMN
        "Mod+BracketLeft".consume-or-expel-window-left = [];
        "Mod+BracketRight".consume-or-expel-window-right = [];

        # RELOAD CONFIG
        "Mod+Alt+R".spawn-sh = ["niri msg action load-config-file"];

        # CLOSE WINDOW
        "Mod+Q" = {
          _props = {repeat = false;};
          close-window = [];
        };

        # MOVE VIA MOUSE
        "Mod+WheelScrollDown" = {
          _props = {cooldown-ms = 150;};
          focus-workspace-down = [];
        };
        "Mod+WheelScrollUp" = {
          _props = {cooldown-ms = 150;};
          focus-workspace-up = [];
        };
        "Mod+Shift+WheelScrollUp" = {
          _props = {cooldown-ms = 150;};
          focus-column-left-or-last = [];
        };
        "Mod+Shift+WheelScrollDown" = {
          _props = {cooldown-ms = 150;};
          focus-column-right-or-first = [];
        };

        # FULL SCREEN
        "Mod+F".fullscreen-window = [];

        # RESIZE WINDOW
        "Mod+Minus".set-column-width = "-5%";
        "Mod+Equal".set-column-width = "+5%";
        "Mod+Alt+Minus".set-window-height = "-5%";
        "Mod+Alt+Equal".set-window-height = "+5%";

        # TOGGLE FLOATING
        "Mod+Shift+F".toggle-window-floating = [];

        # FOCUS WINDOW
        "Mod+Left".focus-column-or-monitor-left = [];
        "Mod+Down".focus-window-or-workspace-down = [];
        "Mod+Up".focus-window-or-workspace-up = [];
        "Mod+Right".focus-column-or-monitor-right = [];

        # MOVE WINDOW
        "Mod+Shift+Left".move-column-left-or-to-monitor-left = [];
        "Mod+Shift+Down".move-window-down-or-to-workspace-down = [];
        "Mod+Shift+Up".move-window-up-or-to-workspace-up = [];
        "Mod+Shift+Right".move-column-right-or-to-monitor-right = [];

        # MOVE TO WORKSPACE
        "Mod+1".focus-workspace = "1";
        "Mod+2".focus-workspace = "2";
        "Mod+3".focus-workspace = "3";
        "Mod+4".focus-workspace = "4";
        "Mod+5".focus-workspace = "5";
        "Mod+6".focus-workspace = "6";
        "Mod+7".focus-workspace = "7";
        "Mod+8".focus-workspace = "8";
        "Mod+9".focus-workspace = "9";
        "Mod+0".focus-workspace = "10";

        # MOVE WINDOW TO WORKSPACE
        "Mod+Shift+1".move-window-to-workspace = "1";
        "Mod+Shift+2".move-window-to-workspace = "2";
        "Mod+Shift+3".move-window-to-workspace = "3";
        "Mod+Shift+4".move-window-to-workspace = "4";
        "Mod+Shift+5".move-window-to-workspace = "5";
        "Mod+Shift+6".move-window-to-workspace = "6";
        "Mod+Shift+7".move-window-to-workspace = "7";
        "Mod+Shift+8".move-window-to-workspace = "8";
        "Mod+Shift+9".move-window-to-workspace = "9";
        "Mod+Shift+0".move-window-to-workspace = "10";

        # MEDIA & HARDWARE CONTROLS
        XF86AudioRaiseVolume.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
        XF86AudioLowerVolume.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
        XF86AudioMute.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
        XF86AudioPlay.spawn = ["playerctl" "play-pause"];
        XF86AudioPause.spawn = ["playerctl" "play-pause"];
        XF86AudioNext.spawn = ["playerctl" "next"];
        XF86AudioPrev.spawn = ["playerctl" "previous"];

        # APPLICATIONS
        "Mod+Return".spawn = [terminal];
        "Mod+D".spawn = ["discord"];
        "Mod+S".spawn = ["spotify"];
        "Mod+Z".spawn = ["zeditor"];
        "Mod+W".spawn = [browser];
        "Mod+O".spawn = ["obs"];
        "Mod+T".spawn = ["thunar"];
        "Mod+Y".spawn = ["kitty" "-e" "yazi"];
        "Mod+Alt+M".spawn = ["pavucontrol"];
      }
      // lib.listToAttrs (map (b: {
          name = toNiriKey b.key;
          value.spawn-sh = [b.command];
        })
        barBinds);
  };
}
