{
  hosts = ["puffin"];

  module = {
    self,
    pkgs,
    lib,
    system,
    ...
  }: let
    wm = self.wrapperModules.${system};
  in {
    # micro sd card disk layout
    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "noatime"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=1min"
        ];
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = ["noatime"];
      };
    };

    custom = {
      git.enable = false;
      binfmt.enable = false;
      nix-ld.enable = false;
      preservation.enable = false;
      scheduler.enable = false;
      printing.enable = false;
      yubikey.enable = false;

      ssh.hosts = {
        apricot = {};
        mango = {};
        capybara = {};
        "apricot.local" = {};
        "mango.local" = {};
        "capybara.local" = {};
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

      atticd.device = "/dev/disk/by-label/cache";
    };
  };
}
