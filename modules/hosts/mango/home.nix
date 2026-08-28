{config, ...}: let
  wallpaper = ../../../assets/wallpapers/Embraced_A.png;
in {
  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [nix-settings home sops ssh deploy attic syncthing]
      ++ [cli terminals apps editors desktop xdg theme niri noctalia quickshell thunar yazi maa]
      ++ [
        (_: {
          homeManager = {
            ssh.hosts = {
              apricot = {};
              puffin = {};
              "apricot.local" = {};
              "puffin.local" = {};
            };
            attic = {
              tailscaleDomain = "puffin.tail9fb2b9.ts.net";
              lanDomain = "puffin.local";
              cacheName = "mango-home";
              publicKey = "9h3FV2ei8Z1QVA9NiKrhZVI1blxeNwlxTqWQa6rgoJ4=";
            };
            desktop = {
              inherit wallpaper;
              barThemeEnabled = true;
              monitors = [
                {
                  name = "DP-2";
                  width = 1920;
                  height = 1080;
                  x = 0;
                  y = 0;
                  refresh = 164.955;
                }
                {
                  name = "DP-5";
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
                themes = ["noctalia-material.theme.css" "noctalia.theme.css"];
              };
              obs-studio.enable = true;
              spicetify.enable = true;
              vellum.enable = true;
            };
            terminals.kitty.enable = true;
            # terminals.ghostty.enable = true;
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
                theme = "noctalia";
              };
              cava = {
                enable = true;
                theme = "noctalia";
              };
              fastfetch.enable = true;
              bottom.enable = true;
              nh.enable = true;
              tealdeer.enable = true;
              nix-search-tv.enable = true;
              television.enable = true;
              search.enable = true;
              styling.enable = true;
              utils.enable = true;
              eyecandy.enable = true;
            };
            editors = {
              zed.enable = true;
              nano.enable = true;
              nixvim.enable = true;
            };
            theme = {
              matugen = {
                enable = true;
                inherit wallpaper;
                cachedThemeFile = ./_theme.json;
                type = "scheme-fidelity";
              };
              cursor.enable = true;
              qt.enable = true;
              gtk.enable = true;
            };
          };
        })
      ];
  };
}
