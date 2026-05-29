{
  inputs,
  host,
  username,
  pkgs,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage;
in {
  imports = [inputs.stylix.homeModules.stylix];
  stylix = {
    enable = true;
    image = stylixImage;
    opacity.terminal = 0.8;
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      # package = pkgs.nordzy-cursor-theme;
      # name = "Nordzy-cursors";
      size = 24;
    };
    targets = {
      spicetify.enable = true;
      nixcord.enable = true;
      zed.enable = false; # bug not fixed, hardcoded theme in zed.nix
      kitty = {
        enable = true;
        opacity.enable = true;
      };
      firefox = {
        enable = true;
        profileNames = [username];
        colorTheme.enable = true;
      };
      # Avoid fetching GNOME Shell sources on non-GNOME systems (breaks on some remotes)
      gnome.enable = false;
      waybar.enable = false;
      rofi.enable = false;
      hyprland.enable = false; # some conflicts in hyprland settings
      hyprlock.enable = false;
      ghostty.enable = false;
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
