{config, ...}: let
  inherit (config.homeManager.hyprland) terminal;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    hl.env("NIXOS_OZONE_WL", "1")
    hl.env("NIXPKGS_ALLOW_UNFREE", "1")
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
    -- TODO: manual review — malformed env on line 63: GDK_BACKEND, wayland, x11
    hl.env("CLUTTER_BACKEND", "wayland")
    -- TODO: manual review — malformed env on line 65: QT_QPA_PLATFORM=wayland;xcb
    hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
    hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
    hl.env("SDL_VIDEODRIVER", "x11")
    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
    hl.env("GDK_SCALE", "1")
    hl.env("QT_SCALE_FACTOR", "1")
    hl.env("EDITOR", "nvim")
    hl.env("TERMINAL", "${terminal}")
    hl.env("XDG_TERMINAL_EMULATOR", "${terminal}")
  '';
}
