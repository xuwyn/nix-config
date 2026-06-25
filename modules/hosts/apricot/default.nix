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
      cli
      sops
      python
      nh
      kitty

      # editors
      nano
      nixvim
      zed

      # desktop
      yazi
      fonts
      stylix

      # extra
      umbrella-fetch

      (_: {
        homeManager = {
          git = {
            username = "wyn";
            email = "173407133+suquynh@users.noreply.github.com";
          };
          btop.stylixTheme.enable = true;
          cava.stylixTheme.enable = true;
          starship.stylixTheme.enable = true;
          stylix.image = stylixImage;
        };
      })
    ];
  };
}
