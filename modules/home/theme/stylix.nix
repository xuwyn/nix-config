{
  flake.modules.homeManager.stylix = {
    inputs,
    username,
    pkgs,
    config,
    lib,
    ...
  }: let
    hyprlandEnable = config.homeManager.hyprland.enable or false;
    i3Enable = config.homeManager.i3.enable or false;

    cfg = config.homeManager.stylix;
  in {
    options.homeManager.stylix = {
      image = lib.mkOption {
        type = lib.types.path;
        description = "Set stylix image relative path";
      };
    };
    imports = [inputs.stylix.homeModules.stylix];
    config = {
      stylix =
        {
          enable = true;
          image = cfg.image;
          opacity.terminal = 0.95;
          polarity = "dark";
          targets = {
            btop = {
              enable = true;
              colors.enable = config.homeManager.btop.stylixTheme.enable or false;
              opacity.enable = true;
            };
            cava = {
              enable = config.homeManager.cava.stylixTheme.enable or false;
              colors.enable = config.homeManager.cava.stylixTheme.enable or false;
              rainbow.enable = config.homeManager.cava.stylixTheme.enable or false;
            };
            kitty = {
              enable = true;
              fonts.enable = false;
              colors.enable = !(config.homeManager.kitty.barTheme.enable or false);
              variant256Colors = !(config.homeManager.kitty.barTheme.enable or false);
              opacity.enable = true;
            };
            ghostty = {
              enable = true;
              fonts.enable = false;
              colors.enable = !(config.homeManager.ghostty.barTheme.enable or false);
              opacity.enable = true;
            };
            starship = {
              enable = config.homeManager.starship.stylixTheme.enable or false;
              colors.enable = config.homeManager.starship.stylixTheme.enable or false;
            };
            nixcord.enable = config.homeManager.nixcord.stylixTheme.enable or false;
            spicetify.enable = true;
            zed.enable = false; # bug not fixed, hardcoded theme in zed.nix
            nixvim.enable = false;
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
            kde.enable = false;
            gtk.enable = config.homeManager.gtk.stylixTheme.enable or false;
            qt = {
              enable = config.homeManager.qt.stylixTheme.enable or false;
              platform = "qtct";
            };
          };
        }
        // (
          if hyprlandEnable || i3Enable
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
    };
  };
}
