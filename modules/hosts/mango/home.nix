{config, ...}: {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [home]
      ++ [editors desktop noctalia hyprland]
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
              # nixvim.enable = true;
            };
          };
        })
      ];
  };
}
