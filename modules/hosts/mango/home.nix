{config, ...}: {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [nix-settings home sops ssh deploy attic syncthing]
      ++ [terminals apps editors desktop xdg theme umbriel noctalia thunar yazi maa]
      ++ [
        ({
          self,
          pkgs,
          ...
        }: {
          home.packages = [];
          homeManager = {
            ssh.hosts = {
              apricot = {};
              puffin = {};
              "apricot.local" = {};
              "puffin.local" = {};
            };
            desktop = {
              inherit wallpaper;
              barThemeEnabled = true;
              monitors = [
                {
                  name = "DP-1";
                  width = 1920;
                  height = 1080;
                  x = 0;
                  y = 0;
                  refresh = 164.955;
                }
                {
                  name = "DP-4";
                  width = 1920;
                  height = 1080;
                  x = 0;
                  y = 0;
                  refresh = 164.955;
                }
              ];
              startupCommands = [
                "fcitx5 -d -r"
                "pkill openrgb; sleep 1; openrgb --startminimized --profile purple;"
              ];
            };
            apps = {
              firefox.enable = true;
              mangohud = {
                enable = true;
                fpsLimit = 165;
              };
              nixcord = {
                enable = true;
                themes = ["noctalia.theme.css"];
              };
              spicetify.enable = true;
              vellum.enable = true;
            };
            terminals.kitty.enable = true;
            terminals.ghostty.enable = true;
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
