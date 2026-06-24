{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) fpsLimit;
in {
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      no_display = true;
      fps_limit = fpsLimit;
      vsync = 1;
    };
  };
}
