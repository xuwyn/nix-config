{config, ...}: let
  wallpaper = ../../../wallpapers/DaVinci.jpg;
in {
  nixos.lettuce = {
    host = "lettuce";
    profile = "wsl";
    users = ["wyn"];
    modules = with config.modules.nixos; [
      network
      security
      system
      users
    ];
  };

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
            fastfetch = {
              enable = true;
              terminal = "wezterm";
            };
            btop.enable = true;
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
            nano.enable = true;
            nixvim.enable = true;
          };
          theme = {
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
