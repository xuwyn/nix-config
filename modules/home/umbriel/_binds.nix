{
  config,
  lib,
  ...
}: let
  inherit (config.homeManager.desktop) browser terminal;
  noctaliaBinds = import ../noctalia/_binds.nix;
  toUmbrielKey = key: let
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
      else if p == "ESCAPE"
      then "Escape"
      else p;
  in
    lib.concatStringsSep "+" (map rename parts);
in
  {
    # Applications and session
    "Mod+Return" = "spawn:${terminal}";
    "Mod+W" = "spawn:${browser}";
    "Mod+D" = "spawn:discord";
    "Mod+S" = "spawn:spotify";
    "Mod+Z" = "spawn:zeditor";
    "Mod+O" = "spawn:obs";
    "Mod+T" = "spawn:thunar";
    "Mod+Y" = "spawn:${terminal} yazi";
    "Mod+Shift+Escape" = "spawn:${terminal} btop";
    "Mod+Ctrl+A" = "spawn:vellum toggle";
    "Mod+Q" = "window-close";
    "Mod+Delete" = "session-quit";
    "Mod+Slash" = "cheatsheet-toggle";

    # Focus navigation
    "Mod+Shift+WheelUp" = "window-focus-right";
    "Mod+Shift+WheelDown" = "window-focus-left";
    "Mod+Left" = "window-focus-left";
    "Mod+Down" = "window-focus-or-workspace-down";
    "Mod+Up" = "window-focus-or-workspace-up";
    "Mod+Right" = "window-focus-right";
    "Mod+H" = "window-focus-left";
    "Mod+J" = "window-focus-or-workspace-down";
    "Mod+K" = "window-focus-or-workspace-up";
    "Mod+L" = "window-focus-right";
    "Alt+Tab" = "window-focus-last";

    # Window state and layout
    "Mod+Shift+F" = "window-toggle-floating";
    "Mod+F" = "window-toggle-fullscreen";
    "Mod+Ctrl+F" = "window-toggle-maximize";

    # Overview
    "Mod+Tab" = {
      action = "overview-toggle";
      repeat = false;
    };

    # Windows/columns movement
    "Mod+Shift+Left" = "column-move-left";
    "Mod+Shift+Down" = "window-move-or-workspace-down";
    "Mod+Shift+Up" = "window-move-or-workspace-up";
    "Mod+Shift+Right" = "column-move-right";
    "Mod+Shift+H" = "column-move-left";
    "Mod+Shift+J" = "window-move-or-workspace-down";
    "Mod+Shift+K" = "window-move-or-workspace-up";
    "Mod+Shift+L" = "column-move-right";
    "Mod+Ctrl+Shift+Up" = "window-move-to-workspace-previous";
    "Mod+Ctrl+Shift+Down" = "window-move-to-workspace-next";
    "Mod+Ctrl+Shift+K" = "window-move-to-workspace-previous";
    "Mod+Ctrl+Shift+J" = "window-move-to-workspace-next";
    "Mod+Bracketright" = "window-consume-or-expel-right";
    "Mod+Bracketleft" = "window-consume-or-expel-left";

    # Workspace movement
    "Mod+Alt+J" = "workspace-move-down";
    "Mod+Alt+K" = "workspace-move-up";
    "Mod+Alt+Down" = "workspace-move-down";
    "Mod+Alt+Up" = "workspace-move-up";

    # Workspaces
    "Mod+Shift+Tab" = "workspace-set-layout:toggle";
    "Mod+WheelDown" = "workspace-next";
    "Mod+WheelUp" = "workspace-previous";
    "Mod+Ctrl+Up" = "workspace-previous";
    "Mod+Ctrl+Down" = "workspace-next";
    "Mod+Ctrl+J" = "workspace-next";
    "Mod+Ctrl+K" = "workspace-previous";
    "Mod+1" = "workspace-switch:1";
    "Mod+2" = "workspace-switch:2";
    "Mod+3" = "workspace-switch:3";
    "Mod+4" = "workspace-switch:4";
    "Mod+5" = "workspace-switch:5";
    "Mod+6" = "workspace-switch:6";
    "Mod+7" = "workspace-switch:7";
    "Mod+8" = "workspace-switch:8";
    "Mod+9" = "workspace-switch:9";
    "Mod+Shift+1" = "window-move-to-workspace:1";
    "Mod+Shift+2" = "window-move-to-workspace:2";
    "Mod+Shift+3" = "window-move-to-workspace:3";
    "Mod+Shift+4" = "window-move-to-workspace:4";
    "Mod+Shift+5" = "window-move-to-workspace:5";
    "Mod+Shift+6" = "window-move-to-workspace:6";
    "Mod+Shift+7" = "window-move-to-workspace:7";
    "Mod+Shift+8" = "window-move-to-workspace:8";
    "Mod+Shift+9" = "window-move-to-workspace:9";

    # Scratchpads
    "Mod+Shift+Space" = "window-move-to-scratchpad";
    "Mod+Space" = "scratchpad-toggle";
    "Mod+Ctrl+Space" = "window-restore-from-scratchpad";

    # Window Resize
    "Mod+Minus" = "window-modify-width:-0.1";
    "Mod+Equal" = "window-modify-width:0.1";
    "Mod+Alt+Minus" = "window-modify-height:-0.1";
    "Mod+Alt+Equal" = "window-modify-height:0.1";

    # Media and brightness
    "XF86AudioRaiseVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
    "XF86AudioLowerVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
    "XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    "XF86AudioPlay" = "spawn:playerctl play-pause";
    "XF86AudioNext" = "spawn:playerctl next";
    "XF86AudioPrev" = "spawn:playerctl previous";
  }
  // lib.listToAttrs (map (b: {
      name = toUmbrielKey b.key;
      value = "spawn:${b.command}";
    })
    noctaliaBinds)
