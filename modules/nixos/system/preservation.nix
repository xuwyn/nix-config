{
  platforms = ["linux"];
  module = {
    flake,
    config,
    lib,
    inputs,
    users,
    ...
  }: let
    cfg = config.custom.preservation;
    inherit (lib) types mkOption mapAttrs;
  in {
    imports = [inputs.preservation.nixosModules.preservation];

    options.custom.preservation = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "btrfs root wipe on boot, with /persist preserved";
      };
      directories = mkOption {
        type = types.listOf (types.either types.str (types.attrsOf types.anything));
        default = [];
      };
      files = mkOption {
        type = types.listOf (types.either types.str (types.attrsOf types.anything));
        default = [];
      };
      users = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            directories = mkOption {
              type = types.listOf (types.either types.str (types.attrsOf types.anything));
              default = [];
            };
            files = mkOption {
              type = types.listOf (types.either types.str (types.attrsOf types.anything));
              default = [];
            };
          };
        });
        default = {};
      };
    };

    config = lib.mkIf cfg.enable {
      # fix user ownership in /home
      systemd.tmpfiles.rules = map (userName: "d /home/${userName} 0700 ${userName} users -") users;

      # Suppress machine-id commit service if not using the 'firstboot' pattern
      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

      # Need these folders for boot
      fileSystems = {
        "/nix".neededForBoot = true;
        "/persist".neededForBoot = true;
      };

      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories =
            [
              "/etc/NetworkManager"
              "/var"
              {
                directory = "/etc/ssh";
                inInitrd = true;
              }
            ]
            ++ cfg.directories;
          files =
            [
              {
                file = "/etc/machine-id";
                inInitrd = true;
              }
            ]
            ++ cfg.files;

          users = let
            defaultUserDirectories = [
              flake.homeRelativePath
              ".config"
              ".local"
              ".ssh"
              ".gnupg"
              ".pki"
              "Documents"
              "Downloads"
              "Pictures"
              "Videos"
              "Music"
            ];
            defaultUserFiles = [];
          in
            mapAttrs
            (_: u: {
              directories = defaultUserDirectories ++ u.directories;
              files = defaultUserFiles ++ u.files;
            })
            cfg.users;
        };
      };

      # Btrfs snapshot and wipe root
      boot.initrd.systemd.services.btrfs-root-rotate = {
        wantedBy = ["initrd.target"];
        after = ["systemd-cryptsetup@cryptroot.service"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs_tmp
          mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp
          if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +10); do
            delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };
    };
  };
}
