{config, ...}: let
  inherit (config.homeManager.desktop) terminal;
in {
  wayland.windowManager.niri.settings.environment = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    CLUTTER_BACKEND = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    SDL_VIDEODRIVER = "x11";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    GDK_SCALE = "1";
    QT_SCALE_FACTOR = "1";
    EDITOR = "nvim";
    TERMINAL = terminal;
    XDG_TERMINAL_EMULATOR = terminal;
  };
}
