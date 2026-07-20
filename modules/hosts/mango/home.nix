{config, ...}: let
  wallpaper = ../../../assets/wallpapers/summertime-rendering.png;
in {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      home
      cli
      sops
      quickshell
      terminals
      apps
      editors
      theme
      syncthing
      desktop
      hyprland
      noctalia
      xdg
      thunar
      yazi
      maa

      (_: {
        homeManager = {
          desktop = {
            inherit wallpaper;
            qylockEnabled = true;
            barThemeEnabled = true;
            monitors = [
              {
                name = "DP-5";
                width = 1920;
                height = 1080;
                x = 0;
                y = 0;
                refresh = 165;
              }
              {
                name = "DP-2";
                width = 1920;
                height = 1080;
                x = 0;
                y = 0;
                refresh = 165;
              }
            ];
          };
          apps = {
            firefox.enable = true;
            mangohud = {
              enable = true;
              fpsLimit = 165;
            };
            nixcord = {
              enable = true;
              themes = ["noctalia-material.theme.css" "noctalia.theme.css"];
              # themes = ["dank-discord.css"];
            };
            obs-studio.enable = true;
            spicetify.enable = true;
          };
          terminals = {
            kitty.enable = true;
            # ghostty.enable = true;
          };
          cli = {
            zsh.enable = true;
            bash.enable = true;
            git = {
              enable = true;
              username = "wyn";
              email = "173407133+xuwyn@users.noreply.github.com";
            };
            btop = {
              enable = true;
              theme = "noctalia";
            };
            cava = {
              enable = true;
              theme = "noctalia";
            };
            fastfetch = {
              enable = true;
              logo = "png";
            };
            nh.enable = true;
            tealdeer.enable = true;
            nix-search-tv.enable = true;
            television.enable = true;
            search.enable = true;
            styling.enable = true;
            utils.enable = true;
            eyecandy.enable = true;
          };
          editors = {
            zed.enable = true;
            nano.enable = true;
            nixvim.enable = true;
          };
          theme = {
            matugen = {
              enable = true;
              type = "scheme-fidelity";
            };
            cursor.enable = true;
            qt.enable = true;
            gtk.enable = true;
          };
        };
      })
    ];
  };
}
