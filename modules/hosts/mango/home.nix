{config, ...}: {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [nix-settings home sops]
      ++ [apps editors desktop xdg theme thunar maa noctalia hyprland]
      ++ [
        ({
          self,
          pkgs,
          ...
        }: {
          homeManager = {
            desktop = {
              barThemeEnabled = true;
            };
            apps = {
              # firefox.enable = true;
              # mangohud = {
              #   enable = true;
              #   fpsLimit = 165;
              # };
              # nixcord = {
              #   enable = true;
              #   themes = ["noctalia.theme.css"];
              # };
              # spicetify.enable = true;
              # vellum.enable = true;
            };
            editors = {
              zed.enable = true;
              nano.enable = true;
              nixvim.enable = true;
            };
            theme = {
              cursor.enable = true;
              qt.enable = true;
              gtk.enable = true;
            };
          };
        })
      ];
  };
}
