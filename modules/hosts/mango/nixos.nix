{config, ...}: {
  nixos.mango = {
    system = "x86_64-linux";
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [./_disko.nix nix-settings preservation drivers boot hardware network]
      ++ [system users desktop apps services sops tailscale deploy binfmt]
      ++ [
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
            users = {
              wyn = {
                isAdmin = true;
                sshKeys = [../../common/keys/openssh_key.pub];
              };
              deploy = {
                isDeployer = true;
                sshKeys = [../../common/keys/deploy_key.pub];
              };
            };
            preservation.users.wyn = {
              directories = [
                "Shared"
                ".android"
                ".mozilla"
                ".steam"
              ];
              files = [
                {
                  file = ".gitconfig";
                  how = "symlink";
                }
                {
                  file = ".bash_history";
                  how = "symlink";
                }
                {
                  file = ".zsh_history";
                  how = "symlink";
                }
              ];
            };
            desktop = {
              displayManager = {
                enable = true;
                mode = "qylock";
              };
              niri.enable = true;
              fonts.enable = true;
              thunar.enable = true;
              utils.enable = true;
            };
            apps = {
              gpu-screen-recorder.enable = true;
              openrgb.enable = true;
              steam.enable = true;
            };
            services = {
              scheduler = {
                scx.enable = true;
                ananicy.enable = true;
              };
              printing.enable = true;
              waydroid.enable = true;
            };
          };
        })
      ];
  };
}
