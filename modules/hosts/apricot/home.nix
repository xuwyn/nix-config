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
      nix-settings
      home
      apps
      sops
      ssh
      syncthing
      cli
      editors
      terminals
      yazi
      theme
      aerospace
      maa

      (_: {
        sops.secrets = {
          syncthing_password = {};
          deploy_key = {};
        };
      })
      (_: {
        homeManager = {
          apps.nixcord.enable = true;
          ssh.hosts = {
            mango = {};
            capybara = {};
            potato = {};
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
            };
          };
        };
      })
    ];
  };
}
