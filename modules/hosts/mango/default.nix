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

      displayManager
      fonts
      hyprland
      qylock
      stylix
      thunar
      utilities
      xserver

      gpu-screen-recorder
      openrgb
      steam

      printing

      (_: {
        nixos = {
          amd-nvidia-sync = {
            nvidiaID = "PCI:1:0:0";
            amdgpuID = "PCI:15:0:0";
          };
          network.hostId = "5ab03f50";
          boot.cachyOSKernel.enable = true;
          displayManager.mode = "silent";
          stylix.image = stylixImage;
        };
      })
    ];
  };

  home."wyn@mango" = {
    system = "x86_64-linux";
    host = "mango";
    username = "wyn";
    modules = [];
  };
}
