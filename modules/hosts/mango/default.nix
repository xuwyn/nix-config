{config, ...}: let
  stylixImage = ../../../wallpapers/interlude_MDxBA_1.png;
in {
  nixos.mango = {
    host = "mango";
    profile = "amd-nvidia-sync";
    username = "wyn";
    modules = with config.flake.modules.nixos; [
      ./_hardware.nix
      boot
      hardware
      network
      nix-conf
      security
      system
      user

      # desktop
      displayManager
      fonts
      hyprland
      qylock
      stylix
      thunar
      utilities
      xserver

      # apps
      gpu-screen-recorder
      openrgb
      steam

      # services
      printing

      ({pkgs, ...}: {
        nixos = {
          amd-nvidia-sync = {
            nvidiaID = "PCI:1:0:0";
            amdgpuID = "PCI:15:0:0";
          };
          network.hostId = "5ab03f50";
          boot.cachyOSKernel = {
            enable = true;
            package = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
          };
          displayManager.mode = "silent";
          stylix.image = stylixImage;
        };
      })
    ];
  };

  home."wyn@mango" = {
    system = "x86_64-linux";
    username = "wyn";
    modules = with config.flake.modules.homeManager; [
      home
      cli
      sops
      python
      quickshell
      nh
      kitty

      # apps
      firefox
      nixcord
      obs-studio
      spicetify
      mangohud

      # editors
      nano
      nixvim
      zed

      # desktop/hyprland
      dotfiles
      hyprland
      noctalia
      rofi
      xdg
      thunar
      yazi
      fonts
      stylix
      gtk
      qt

      # extra
      umbrella-fetch

      (_: {
        homeManager = {
          git = {
            username = "wyn";
            email = "173407133+xuwyn@users.noreply.github.com";
          };
          btop.theme = "noctalia";
          cava.theme = "noctalia";
          nixcord.themes = ["noctalia-material.theme.css" "noctalia.theme.css"];
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
            barChoice = "noctalia";
            barTheme.enable = true;
            qylock.enable = true;
          };
          mangohud.fpsLimit = 165;
          stylix.image = stylixImage;
          rofi.background = stylixImage;
          kitty = {
            barChoice = "noctalia";
            barTheme.enable = true;
          };
          gtk.stylixTheme.enable = true;
          qt.stylixTheme.enable = true;
        };
      })
    ];
  };
}
