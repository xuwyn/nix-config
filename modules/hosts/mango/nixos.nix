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
    imports = [./_disko.nix];
    environment.systemPackages = with wm; [
      (bottom {})
      (cava {noctaliaThemeEnabled = true;})
      (btop {noctaliaThemeEnabled = true;})
      (kitty {noctaliaThemeEnabled = true;})
      (zed-editor {noctaliaThemeEnabled = true;})
      (helix {})
      (sonora {noctaliaThemeEnabled = true;})
      (yazi {})
      (firefox {})
      (spicetify {})
      (maa-cli {})
      (nvf {})
      inputs.umbrella-fetch.packages.${system}.default
    ];

    sops.age = {
      keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
      plugins = [pkgs.age-plugin-yubikey];
    };

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;

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
    };
  };
}
