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
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
    targets = {
      btop.enable = false;
      spicetify.enable = false;
      nixcord.enable = false;
      zed.enable = false; # bug not fixed, hardcoded theme in zed.nix
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
      gtk.enable = true;
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
