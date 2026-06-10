{host, ...}: let
  vars = import ../../../hosts/${host}/variables.nix;
  inherit
    (vars)
    barChoice
    ;
  # Noctalia-specific startup commands
  noctaliaExec =
    if barChoice == "noctalia"
    then [
      "noctalia &" # let noctalia handle openrgb
    ]
    else [];
in {
  wayland.windowManager.hyprland.settings = {
    exec-once =
      [
        "wl-paste --type text --watch cliphist store" # Saves text
        "wl-paste --type image --watch cliphist store" # Saves images
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "hyprland-change-layout init"
      ]
      ++ noctaliaExec;
  };
}
