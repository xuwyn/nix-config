{
  config,
  inputs,
  ...
}: let
  stylixImage = ../../../wallpapers/Amiya-Birthday-Skin-Promote.png;
in {
  home."wyn@apricot" = {
    system = "aarch64-darwin";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      inputs.mac-app-util.homeManagerModules.default
      home
      sops
      python
      cli
      editors
      terminals
      yazi
      theme
      aerospace

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
          terminals.kitty.enable = true;
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
