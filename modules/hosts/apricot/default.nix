{
  config,
  inputs,
  ...
}: let
  wallpaper = ../../../assets/wallpapers/Amiya-Birthday-Skin-Promote.png;
in {
  home."wyn@apricot" = {
    system = "aarch64-darwin";
    username = "wyn";
    modules = with config.modules.homeManager; [
      inputs.mac-app-util.homeManagerModules.default
      home
      sops
      syncthing
      cli
      editors
      terminals
      yazi
      theme
      aerospace

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
            btop.enable = true;
            cava.enable = true;
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
