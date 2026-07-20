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
      theme
      xdg
      thunar
      yazi
      syncthing

      (_: {
        homeManager = {
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
            fonts.enable = true;
            matugen = {
              enable = true;
              inherit wallpaper;
            };
          };
        };
      })
    ];
  };
}
