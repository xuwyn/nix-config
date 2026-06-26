{config, ...}: let
  stylixImage = ../../../wallpapers/voyager.png;
in {
  home."wyn@potato" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      ./_gpu.nix
      home
      cli
      sops
      python
      nh
      kitty

      # apps
      firefox
      nixcord
      spicetify

      # editors
      nano
      nixvim
      zed

      # desktop/i3
      i3
      polybar
      dunst
      picom
      rofi
      xdg
      thunar
      yazi
      fonts
      stylix
      gtk

      # extra
      umbrella-fetch

      (_: {
        homeManager = {
          git = {
            username = "wyn";
            email = "173407133+xuwyn@users.noreply.github.com";
          };
          btop.stylixTheme.enable = true;
          cava.stylixTheme.enable = true;
          nixcord.stylixTheme.enable = true;
          i3 = {
            enable = true;
            monitors = [
              {
                name = "DP-2";
                refreshRate = "164.96";
                workspaces = ["1" "2" "3" "4" "5"];
              }
            ];
            background = stylixImage;
          };
          stylix.image = stylixImage;
          rofi.background = stylixImage;
          gtk.stylixTheme.enable = true;
        };
      })
    ];
  };
}
