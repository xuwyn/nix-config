{
  targets = ["nopal"];
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
    # imports = [./_hardware-configuration.nix];

    # put these here temporarily
    boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/cryptroot";

    swapDevices = [
      {
        device = "/dev/disk/by-partlabel/swap";
        randomEncryption.enable = true;
      }
    ];

    fileSystems = let
      btrfs = subvol: {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = ["subvol=${subvol}" "compress=zstd" "noatime"];
      };
    in {
      "/" = btrfs "root";
      "/nix" = btrfs "nix";
      "/persist" = btrfs "persist" // {neededForBoot = true;};
      "/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
        options = ["umask=0077"];
      };
    };

    environment.systemPackages = with wm; [
      (ff {})
      (bottom {})
      (firefox {})
      (nvf {})
      (cava {noctaliaThemeEnabled = true;})
      (btop {noctaliaThemeEnabled = true;})
      (kitty {noctaliaThemeEnabled = true;})
      (zeditor {noctaliaThemeEnabled = true;})
      (sonora {noctaliaThemeEnabled = true;})
      (yazi {noctaliaThemeEnabled = true;})
    ];

    sops.age = {
      keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
      plugins = [pkgs.age-plugin-yubikey];
    };

    programs = {
      nixcord.enable = false;
      steam.enable = false;
    };

    services.openrgb.enable = false;
    virtualisation.waydroid.enable = false;

    custom = {
      binfmt.enable = false;
      nix-ld.enable = false;
      printing.enable = false;

      ssh.hosts = {
        apricot = {};
        puffin = {};
        mango = {};
        "apricot.local" = {};
        "puffin.local" = {};
        "mango.local" = {};
      };

      displayManager.mode = "tui";

      desktop = {
        monitors = {
          name = "eDP-1";
          width = 1440;
          height = 900;
          x = 0;
          y = 0;
          refresh = 60;
        };

        startupCommands = [
          "fcitx5 -d -r"
        ];
      };
    };
  };
}
