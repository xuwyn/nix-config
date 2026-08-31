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
    modules = with config.modules.homeManager;
      [inputs.mac-app-util.homeManagerModules.default]
      ++ [nix-settings home sops ssh deploy syncthing attic]
      ++ [desktop omniwm apps cli editors terminals theme yazi maa]
      ++ [
        (_: {
          homeManager = {
            apps = {
              nixcord.enable = true;
              spicetify.enable = true;
            };
            ssh.hosts = {
              puffin = {};
              mango = {};
              capybara = {};
              potato = {};
              "puffin.local" = {};
              "mango.local" = {};
              "capybara.local" = {};
              "potato.local" = {};
            };
            cli = {
              zsh = {
                enable = true;
                extraShellAliases = {
                  tailscale-restart = "sudo launchctl kickstart -k system/com.tailscale.tailscaled";
                };
              };
              git = {
                enable = true;
                username = "wyn";
                email = "173407133+xuwyn@users.noreply.github.com";
              };
              btop.enable = true;
              cava.enable = true;
              fastfetch.enable = true;
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
            terminals.kitty.enable = true;
            theme = {
              fonts.enable = true;
              matugen = {
                enable = true;
                inherit wallpaper;
                cachedThemeFile = ./_theme.json;
              };
            };
          };
        })
      ];
  };
}
