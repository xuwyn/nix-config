{
  config,
  lib,
  ...
}: let
  inherit (config.homeManager.hyprland) barName;
  inherit (config.homeManager.theme.matugen) wallpaper;
  wallpaperName = builtins.baseNameOf (toString wallpaper);

  barExec =
    if barName == "noctalia"
    then ''
      hl.exec_cmd("noctalia &")''
    else if barName == "dms"
    then ''
      hl.exec_cmd("dms run -d && sleep 2 && dms ipc call wallpaper set $HOME/Pictures/Wallpapers/${wallpaperName}")''
    else '''';
in {
  wayland.windowManager.hyprland.settings = {
    on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
            hl.exec_cmd("wl-paste --type text --watch cliphist store")
            hl.exec_cmd("wl-paste --type image --watch cliphist store")
            hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
            hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
            hl.exec_cmd("systemctl --user start hyprpolkitagent")
            hl.exec_cmd("fcitx5 -d -r")
            hl.exec_cmd("pkill openrgb; sleep 1; openrgb --startminimized --profile purple;")
            ${barExec}
          end
        '')
      ];
    };
  };
}
