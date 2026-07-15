{config, ...}: let
  wallpaper = ../../../assets/wallpapers/voyager.png;
in {
  home."wyn@potato" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      ./_gpu.nix
      home
      sops
      cli
      apps
      editors
      terminals
      theme
      syncthing

      # desktop/i3
      i3
      rofi
      xdg
      thunar
      yazi

      # extra
      utils
      eyecandy

      ({pkgs, ...}: {
        homeManager = {
          i3 = {
            enable = true;
            picom.enable = true;
            dunst.enable = true;
            polybar.enable = true;
            monitors = [
              {
                name = "DP-2";
                refreshRate = "164.96";
                workspaces = ["1" "2" "3" "4" "5"];
              }
            ];
            background = wallpaper;
          };
          rofi.background = wallpaper;
          cli = {
            zsh.enable = true;
            git = {
              enable = true;
              username = "wyn";
              email = "173407133+xuwyn@users.noreply.github.com";
            };
            btop.enable = true;
            cava.enable = true;
            fastfetch.enable = true;
            bottom.enable = true;
            htop.enable = true;
            nh.enable = true;
            tealdeer.enable = true;
            nix-search-tv.enable = true;
            television.enable = true;
            search.enable = true;
            styling.enable = true;
          };
          editors = {
            zed.enable = true;
            nano.enable = true;
            nixvim.enable = true;
          };
          apps = {
            firefox.enable = true;
            nixcord.enable = true;
            spicetify.enable = true;
          };
          terminals.kitty.enable = true;
          theme = {
            cursor.enable = true;
            fonts.enable = true;
            matugen = {
              enable = true;
              wallpaper = wallpaper;
            };
            gtk.enable = true;
            qt.enable = true;
          };
        };
      })
    ];
  };
}
