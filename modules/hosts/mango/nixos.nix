{config, ...}: {
  nixos.mango = {
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [./_disko.nix nix-settings preservation drivers boot hardware network zram]
      ++ [system users desktop apps services sops tailscale deploy attic binfmt rs-key]
      ++ [
        ({
          self,
          pkgs,
          lib,
          users,
          ...
        }: let
          wm = self.wrapperModules.${pkgs.stdenv.hostPlatform.system};
        in {
          environment.systemPackages = [
            (wm.zsh {})
            (wm.bash {})
            (wm.ff {})
            (wm.tealdeer {})
            (wm.bottom {})
            (wm.ns {})
            (wm.nh {username = "wyn";})
            (wm.cava {theme = "noctalia";})
            (wm.btop {extraSettings = {color_theme = "noctalia";};})
            # (wm.git {
            #   sshKeyPath = config.sops.secrets.private_ssh_key.path;
            #   extraSettings = {
            #     user = {
            #       name = "wyn";
            #       email = "173407133+xuwyn@users.noreply.github.com";
            #       signingkey = config.sops.secrets.private_ssh_key.path;
            #     };
            #   };
            # })
          ];
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
          nixos = {
            zram.tmpMaxSize = "4096";
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
            users = {
              wyn = {
                isAdmin = true;
                sshKeys = [../../common/keys/openssh_key.pub];
                shell = lib.getExe (wm.zsh {});
              };
              deploy = {
                isDeployer = true;
                sshKeys = [../../common/keys/deploy_key.pub];
                shell = lib.getExe (wm.bash {});
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
                mode = "silent";
              };
              umbriel.enable = true;
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
