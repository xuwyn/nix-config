{config, ...}: let
  inherit (config.homeManager.desktop) terminal;
in {
  wayland.windowManager.hyprland.settings.env = [
    {_args = ["QT_QPA_PLATFORMTHEME" "qt6ct"];}
    {_args = ["NIXOS_OZONE_WL" "1"];}
    {_args = ["NIXPKGS_ALLOW_UNFREE" "1"];}
    {_args = ["XDG_CURRENT_DESKTOP" "Hyprland"];}
    {_args = ["XDG_SESSION_TYPE" "wayland"];}
    {_args = ["XDG_SESSION_DESKTOP" "Hyprland"];}
    {_args = ["CLUTTER_BACKEND" "wayland"];}
    {_args = ["QT_WAYLAND_DISABLE_WINDOWDECORATION" "1"];}
    {_args = ["QT_AUTO_SCREEN_SCALE_FACTOR" "1"];}
    {_args = ["SDL_VIDEODRIVER" "x11"];}
    {_args = ["MOZ_ENABLE_WAYLAND" "1"];}
    {_args = ["ELECTRON_OZONE_PLATFORM_HINT" "wayland"];}
    {_args = ["GDK_SCALE" "1"];}
    {_args = ["QT_SCALE_FACTOR" "1"];}
    {_args = ["EDITOR" "nvim"];}
    {_args = ["TERMINAL" terminal];}
    {_args = ["XDG_TERMINAL_EMULATOR" terminal];}
  ];
}
