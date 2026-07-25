{config, ...}: {
  nixos.mango = {
    host = "mango";
    system = "x86_64-linux";
    users = ["wyn"];
    modules = with config.modules.nixos; [
      ./_disko.nix
      impermanence
      drivers
      boot
      hardware
      network
      security
      system
      users
      desktop
      apps
      services
      sops

      ({pkgs, ...}: {
        nixos = {
          drivers = {
            amdcpu.enable = true;
            nvidia.enable = true;
            nvidia-amd-hybrid = {
              enable = true;
              mode = "sync";
              nvidiaBusId = "PCI:1:0:0";
              amdgpuBusId = "PCI:15:0:0";
            };
          };
          boot.cachyOSKernel = {
            enable = true;
            package = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
          };
          users.admins = ["wyn"];
          desktop = {
            displayManager = {
              enable = true;
              mode = "silent";
            };
            qylock.enable = true;
            hyprland.enable = true;
            niri.enable = true;
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
            waydroid.enable = true;
          };
        };
      })
    ];
  };
}
