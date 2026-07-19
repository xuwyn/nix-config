{config, ...}: let
  inherit (config.homeManager.desktop) terminal bar;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    ${
      if bar == "noctalia"
      then ''''
      else if bar == "dms"
      then ''''
      else ''''
    }
    hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
    hl.env("NIXOS_OZONE_WL", "1")
    hl.env("NIXPKGS_ALLOW_UNFREE", "1")
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
    hl.env("CLUTTER_BACKEND", "wayland")
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
