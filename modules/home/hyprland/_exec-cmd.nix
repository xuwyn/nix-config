{
  config,
  lib,
  ...
}: let
  cfg = config.homeManager.hyprland;

  # Noctalia-specific startup commands
  noctaliaExec =
    if cfg.barName == "noctalia"
    then ["noctalia &"]
    else [];
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
            ${lib.optionalString (noctaliaExec != []) "hl.exec_cmd(\"${builtins.head noctaliaExec}\")"}
          end
        '')
      ];
    };
  };
}
