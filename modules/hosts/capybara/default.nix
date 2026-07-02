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
          apps.firefox.enable = true;
          terminals.kitty.enable = true;
          theme = {
            fonts.enable = true;
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
