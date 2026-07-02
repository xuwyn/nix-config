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
    ];
  };

  home."wyn@lettuce" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      home
      sops
      python
      yazi
      cli
      editors
      theme

      # extra
      dev
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
            btop = {
              enable = true;
              stylixTheme.enable = true;
            };
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
            nano.enable = true;
            nixvim.enable = true;
          };
          theme = {
            stylix = {
              enable = true;
              image = stylixImage;
            };
          };
        };
      })
    ];
  };
}
