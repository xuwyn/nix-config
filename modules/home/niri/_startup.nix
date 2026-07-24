{config, ...}: let
  inherit (config.homeManager.desktop) bar wallpaper;
  wallpaperName = builtins.baseNameOf (toString wallpaper);

  barExec =
    if bar == "noctalia"
    then [["noctalia &"]]
    else if bar == "dms"
    then [["dms run -d && sleep 2 && dms ipc call wallpaper set $HOME/Pictures/Wallpapers/${wallpaperName}"]]
    else [];
in {
  wayland.windowManager.niri.settings.spawn-sh-at-startup =
    [
      ["dbus-update-activation-environment --systemd --all && systemctl --user stop niri-session.target && systemctl --user start niri-session.target"]
      ["wl-paste --type text --watch cliphist store"]
      ["wl-paste --type image --watch cliphist store"]
      ["dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"]
      ["systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"]
      ["fcitx5 -d -r"]
      ["pkill openrgb; sleep 1; openrgb --startminimized --profile purple;"]
    ]
    ++ barExec;
}
