{config, ...}: let
  wallpaper = ../../../assets/wallpapers/DaVinci.jpg;
in {
  home."wyn@lettuce" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      home
      sops
      yazi
      cli
      editors
      theme

      (_: {
        homeManager = {
          cli = {
            bash.enable = true;
            git = {
              enable = true;
              username = "wyn";
              email = "173407133+xuwyn@users.noreply.github.com";
            };
            btop.enable = true;
            nh.enable = true;
            tealdeer.enable = true;
            nix-search-tv.enable = true;
            television.enable = true;
            search.enable = true;
            styling.enable = true;
            utils.enable = true;
          };
          editors = {
            nano.enable = true;
            nixvim.enable = true;
          };
          theme = {
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
