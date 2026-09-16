{config, ...}: let
  inherit (config.homeManager.desktop) terminal;
in {
  ELECTRON_OZONE_PLATFORM_HINT = "auto";
  SDL_VIDEODRIVER = "wayland";
  NIXOS_OZONE_WL = "1";
  QT_QPA_PLATFORMTHEME = "qt6ct";
  QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  MOZ_ENABLE_WAYLAND = "1";
  GDK_SCALE = "1";
  QT_SCALE_FACTOR = "1";
  EDITOR = "nvim";
  TERMINAL = terminal;
  XDG_TERMINAL_EMULATOR = terminal;
}
