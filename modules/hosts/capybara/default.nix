{config, ...}: let
  wallpaper = ../../../wallpapers/interlude_RinLen_5.png;
in {
  home."wyn@capybara" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      ./_gpu.nix
      home
      sops
      python
      cli
      terminals
      apps
      editors
      theme
      xdg
      thunar
      yazi
      syncthing

      # extra
      utils
      eyecandy

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
          apps.firefox.enable = true;
          terminals.kitty.enable = true;
          theme = {
            fonts.enable = true;
            matugen = {
              enable = true;
              wallpaper = wallpaper;
            };
          };
        };
      })
    ];
  };
}
