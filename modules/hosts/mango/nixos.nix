{
  targets = ["mango"];
  module = {
    self,
    pkgs,
    config,
    lib,
    system,
    inputs,
    ...
  }: let
    wm = self.wrapperModules.${system};
  in {
    imports = [inputs.chaotic.nixosModules.default]; # for cachyos kernel

    environment.systemPackages = with wm; [
      (ff {})
      (bottom {})
      (cava {noctaliaThemeEnabled = true;})
      (btop {noctaliaThemeEnabled = true;})
      (kitty {noctaliaThemeEnabled = true;})
      (zeditor {noctaliaThemeEnabled = true;})
      (sonora {noctaliaThemeEnabled = true;})
      (yazi {noctaliaThemeEnabled = true;})
      (firefox {})
      (spicetify {})
      (maa-cli {})
      (helix {})
      (nvf {})
      inputs.cressida.packages.${system}.default # cant wrap it 🥲
      inputs.umbrella-fetch.packages.${system}.default
    ];

    sops.age = {
      keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
      plugins = [pkgs.age-plugin-yubikey];
    };

    boot.kernelPackages = pkgs.linuxPackages_cachyos;
    hardware.nvidia.package = pkgs.nvidia_cachyos;

    services = {
      upower.enable = false;
      power-profiles-daemon.enable = false;
    };

    # use cressida for now
    programs.nixcord.enable = false;

    custom = {
      ssh.hosts = {
        apricot = {};
        puffin = {};
        "apricot.local" = {};
        "puffin.local" = {};
      };

      zram.tmpMaxSize = "4096";

      amd.cpu.enable = true;
      nvidia.hybrid = {
        enable = true;
        mode = "sync";
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:15:0:0";
      };

      deploy.controller.enable = true;

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

      displayManager.mode = "silent";
      nixcord.noctaliaThemeEnabled = true;

      desktop = {
        monitors = map (name: {
          inherit name;
          width = 1920;
          height = 1080;
          x = 0;
          y = 0;
          refresh = 164.955;
        }) ["DP-1" "DP-4"];
        startupCommands = [
          "fcitx5 -d -r"
          "pkill openrgb; sleep 1; openrgb --startminimized --profile purple;"
        ];
      };
    };
  };
}
