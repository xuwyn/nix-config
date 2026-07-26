{config, ...}: let
  wallpaper = ../../../assets/wallpapers/interlude_RinLen_5.png;
in {
  home."wyn@capybara" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      ./_gpu.nix
      home
      sops
      cli
      terminals
      apps
      editors
      desktop
      hyprland
      dms
      theme
      xdg
      thunar
      yazi
      syncthing

      (_: {
        homeManager = {
          desktop = {
            inherit wallpaper;
            barThemeEnabled = true;
            monitors = [
              {
                name = "DP-2";
                width = 1920;
                height = 1080;
                x = 0;
                y = 0;
                refresh = 164.955;
              }
              {
                name = "DP-5";
                width = 1920;
                height = 1080;
                x = 0;
                y = 0;
                refresh = 164.955;
              }
            ];
            startupCommands = [
              "pkill openrgb; sleep 1; openrgb --startminimized --profile blue;"
            ];
          };
          cli = {
            zsh.enable = true;
            bash.enable = true;
            git = {
              enable = true;
              username = "wyn";
              email = "173407133+xuwyn@users.noreply.github.com";
            };
            fastfetch.enable = true;
            bottom.enable = true;
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
          apps.firefox.enable = true;
          terminals.kitty.enable = true;
          theme = {
            matugen = {
              enable = true;
              type = "scheme-tonal-spot";
              inherit wallpaper;
            };
            fonts.enable = true;
            cursor.enable = true;
            qt.enable = true;
            gtk.enable = true;
          };
        };
      })
    ];
  };
}
