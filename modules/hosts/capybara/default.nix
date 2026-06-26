{config, ...}: let
  stylixImage = ../../../wallpapers/interlude_RinLen_5.png;
in {
  home."wyn@capybara" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      ./_gpu.nix
      home
      sops
      python
      nh

      # cli
      fastfetch
      bash
      zsh
      bat
      bottom
      htop
      eza
      fzf
      git
      lazygit
      starship
      tealdeer
      zoxide

      # terminals
      kitty

      # apps
      firefox

      # editors
      nano
      nixvim
      zed

      # desktop
      xdg
      thunar
      yazi
      fonts
      stylix

      # extra
      umbrella-fetch

      (_: {
        homeManager = {
          git = {
            username = "wyn";
            email = "173407133+xuwyn@users.noreply.github.com";
          };
          stylix.image = stylixImage;
        };
      })
    ];
  };
}
