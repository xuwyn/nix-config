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
          impermanence = {
            home = {
              wyn = {
                directories = [
                  "Documents"
                  "Downloads"
                  "Music"
                  "Pictures"
                  "Videos"
                  "Shared"
                  "nix-config"
                  ".local"
                  ".config"
                  ".mozilla"
                  ".cache/nix"
                  ".nix-profile"
                  ".nix-defexpr"
                ];
                files = [
                  ".nix-channels"
                ];
              };
            };
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
                wyn = ../../../assets/face.jpg;
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
}
