{config, ...}: let
  stylixImage = ../../../wallpapers/voyager.png;
in {
  home."wyn@potato" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      ./_gpu.nix
      home
      sops
      python
      cli
      apps
      editors
      terminals
      theme

      # desktop/i3
      i3
      rofi
      xdg
      thunar
      yazi

      # extra
      dev
      utils
      eyecandy

      (_: {
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
            background = stylixImage;
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
              stylixTheme.enable = true;
            };
            cava = {
              enable = true;
              stylixTheme.enable = true;
            };
            fastfetch.enable = true;
            bottom.enable = true;
            htop.enable = true;
            eza.enable = true;
            fzf.enable = true;
            zoxide.enable = true;
            bat.enable = true;
            starship.enable = true;
            nh.enable = true;
            tealdeer.enable = true;
          };
          editors = {
            zed.enable = true;
            nano.enable = true;
            nixvim.enable = true;
          };
          apps = {
            firefox.enable = true;
            nixcord = {
              enable = true;
              stylixTheme.enable = true;
            };
            spicetify.enable = true;
          };
          terminals.kitty.enable = true;
          theme = {
            fonts.enable = true;
            stylix = {
              enable = true;
              image = stylixImage;
            };
            gtk = {
              enable = true;
              stylixTheme.enable = true;
            };
          };
        };
      })
    ];
  };
}
