{config, ...}: let
  wallpaper = ../../../wallpapers/IS-Mysterious_Banquet.png;
in {
  nixos.mango = {
    host = "mango";
    profile = "amd-nvidia-sync";
    users = ["wyn"];
    modules = with config.modules.nixos; [
      ./_hardware.nix
      boot
      hardware
      network
      security
      system
      users
      desktop
      apps
      services

      ({pkgs, ...}: {
        nixos = {
          amd-nvidia-sync = {
            nvidiaID = "PCI:1:0:0";
            amdgpuID = "PCI:15:0:0";
          };
          boot.cachyOSKernel = {
            enable = true;
            package = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
          };
          desktop = {
            displayManager = {
              enable = true;
              mode = "silent";
              profileIcon = {
                wyn = ../../home/face.jpg;
              };
            };
            qylock.enable = true;
            hyprland.enable = true;
            fonts.enable = true;
            thunar.enable = true;
            xserver.enable = true;
            utils.enable = true;
          };
          apps = {
            gpu-screen-recorder.enable = true;
            openrgb.enable = true;
            steam.enable = true;
          };
          services = {
            printing.enable = true;
            nix-ld.enable = true;
          };
        };
      })
    ];
  };

  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.modules.homeManager; [
      home
      cli
      sops
      quickshell
      terminals
      apps
      editors
      theme
      syncthing

      # desktop/hyprland
      hyprland
      # dms
      noctalia
      xdg
      thunar
      yazi

      # extra
      utils
      eyecandy

      (_: {
        homeManager = {
          apps = {
            firefox = {
              enable = true;
              barTheme.enable = true;
            };
            mangohud = {
              enable = true;
              fpsLimit = 165;
            };
            nixcord = {
              enable = true;
              themes = ["noctalia-material.theme.css" "noctalia.theme.css"];
              # themes = ["dank-discord.css"];
            };
            obs-studio.enable = true;
            spicetify.enable = true;
          };
          terminals = {
            kitty = {
              enable = true;
              barTheme.enable = true;
            };
            # ghostty = {
            #   enable = true;
            #   barTheme.enable = true;
            # };
          };
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
            fastfetch = {
              enable = true;
              logo = "png";
            };
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
            zed = {
              enable = true;
              barTheme.enable = true;
            };
            nano.enable = true;
            nixvim = {
              enable = true;
              barTheme.enable = true;
            };
          };
          hyprland = {
            enable = true;
            extraMonitorSettings = ''
              hl.monitor({
                output = "DP-5",
                mode = "1920x1080@165",
                position = "0x0",
                scale = 1,
              })
              hl.monitor({
                output = "DP-2",
                mode = "1920x1080@165",
                position = "0x0",
                scale = 1,
              })
            '';
            barName = "noctalia";
            barTheme.enable = true;
            qylock.enable = true;
          };
          theme = {
            matugen = {
              enable = true;
              wallpaper = wallpaper;
            };
            cursor.enable = true;
            qt = {
              enable = true;
              barTheme.enable = true;
            };
            gtk = {
              enable = true;
              barTheme.enable = true;
            };
          };
        };
      })
    ];
  };
}
