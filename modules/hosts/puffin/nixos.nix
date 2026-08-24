{config, ...}: {
  nixos-rpi.puffin = {
    system = "aarch64-linux";
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [rpi5 nix-settings network system users sops tailscale deploy]
      ++ [
        {
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
          nixos.users = {
            wyn = {
              isAdmin = true;
              sshKeys = [../../common/keys/openssh_key.pub];
              shell = "bash";
            };
            deploy = {
              isDeployer = true;
              sshKeys = [../../common/keys/deploy_key.pub];
              shell = "bash";
            };
          };
        }
      ];
  };
}
