{
  inputs,
  host,
  username,
  pkgs,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  inherit (vars) stylixImage;
  hyprlandEnable = vars.hyprlandEnable or false;
  barThemeEnable = vars.barThemeEnable or false;
  barChoice = vars.barChoice or "";
  stylixThemeEnable = barChoice != "" && !barThemeEnable;
in {
  imports = [inputs.stylix.homeModules.stylix];
  stylix =
    {
      enable = true;
      image = stylixImage;
      opacity.terminal = 0.9;
      polarity = "dark";
      targets = {
        btop.enable = !barThemeEnable;
        cava = {
          enable = stylixThemeEnable;
          colors.enable = stylixThemeEnable;
          rainbow.enable = stylixThemeEnable;
        };
        kitty = {
          enable = true;
          colors.enable = !barThemeEnable;
          variant256Colors = !barThemeEnable;
          opacity.enable = true;
        };
        starship = {
          enable = !barThemeEnable;
          colors.enable = !barThemeEnable;
        };
        nixcord.enable = false;
        spicetify.enable = true;
        zed.enable = false; # bug not fixed, hardcoded theme in zed.nix
        nixvim.enable = false; # use nvim plugin (looks dogshit)
        firefox = {
          enable = true;
          profileNames = [username];
          colorTheme.enable = true;
        };
        # Avoid fetching GNOME Shell sources on non-GNOME systems (breaks on some remotes)
        gnome.enable = false;
        waybar.enable = false;
        rofi.enable = false;
        hyprland.enable = false;
        hyprlock.enable = false;
        ghostty.enable = false;

        gtk.enable = hyprlandEnable;
        qt = {
          enable = hyprlandEnable;
          platform = "qtct";
        };
      };
    }
    // (
      if hyprlandEnable
      then {
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
      }
      else {}
    );
}
