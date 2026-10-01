{config, ...}: {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [nix-settings home sops]
      ++ [editors desktop xdg theme thunar noctalia hyprland]
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
