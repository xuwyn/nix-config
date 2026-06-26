{config, ...}: let
  stylixImage = ../../../wallpapers/DaVinci.jpg;
in {
  nixos.lettuce = {
    host = "lettuce";
    profile = "wsl";
    username = "wyn";
    modules = with config.flake.modules.nixos; [
      network
      nix-conf
      security
      system
      user
      (_: {
        nixos = {
          network.hostId = "ff56a61b"; # not really neccesary lol
        };
      })
    ];
  };

  home."wyn@lettuce" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      home
      cli
      sops
      python
      nh
      yazi

      # editors
      nano
      nixvim

      # theme
      stylix

      # extra
      umbrella-fetch

      (_: {
        homeManager = {
          git = {
            username = "wyn";
            email = "173407133+xuwyn@users.noreply.github.com";
          };
          fastfetch.terminal = "wezterm";
          btop.stylixTheme.enable = true;
          cava.stylixTheme.enable = true;
          stylix.image = stylixImage;
        };
      })
    ];
  };
}
