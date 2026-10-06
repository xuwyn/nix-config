{config, ...}: {
  nixos.mango = {
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [./_disko.nix nix-settings preservation drivers boot hardware network zram hjem ssh xdg]
      ++ [system users desktop apps services sops tailscale deploy attic binfmt rs-key git]
      ++ [
        ({
          self,
          pkgs,
          config,
          lib,
          users,
          inputs,
          ...
        }: let
          wm = self.wrapperModules.${pkgs.stdenv.hostPlatform.system};
        in {
          environment.systemPackages = with wm; [
            (zsh {})
            (bash {})
            (ff {})
            (tealdeer {})
            (bottom {})
            (ns {})
            (nh {})
            (cava {noctaliaThemeEnabled = true;})
            (btop {noctaliaThemeEnabled = true;})
            (kitty {noctaliaThemeEnabled = true;})
            (ghostty {noctaliaThemeEnabled = true;})
            (yazi {})
            (firefox {})
            (spicetify {})
            (maa-cli {})
            (helix {})
          ];
          sops.age = {
            keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
            plugins = [pkgs.age-plugin-yubikey];
          };
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
          nixos = {
            ssh.hosts = {
              apricot = {};
              puffin = {};
              "apricot.local" = {};
              "puffin.local" = {};
            };
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
              hyprland.enable = true;
              noctalia.enable = true;
              fonts.enable = true;
              gtk.enable = true;
              qt.enable = true;
              cursor.enable = true;
              thunar.enable = true;
              utils.enable = true;
              monitors = [
                {
                  name = "DP-1";
                  width = 1920;
                  height = 1080;
                  x = 0;
                  y = 0;
                  refresh = 164.955;
                }
                {
                  name = "DP-4";
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
              gpu-screen-recorder.enable = true;
              openrgb.enable = true;
              steam.enable = true;
              nixcord = {
                enable = true;
                themes = ["noctalia.theme.css"];
              };
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
