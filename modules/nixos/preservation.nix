{
  modules.nixos.preservation = {
    flake,
    config,
    lib,
    inputs,
    users,
    ...
  }: let
    cfg = config.nixos.preservation;
    inherit (lib) types mkOption mapAttrs nameValuePair;
  in {
    options.nixos.preservation = {
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

    imports = [inputs.preservation.nixosModules.preservation];

    config = {
      # fix user ownership in /home
      systemd.tmpfiles.rules = map (userName: "d /home/${userName} 0700 ${userName} users -") users;
      # Suppress machine-id commit service if not using the 'firstboot' pattern
      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

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

      # Activate home manager symlink
      systemd.services = let
        mkHomeManagerActivation = userName: let
          homeDir = config.users.users.${userName}.home;
          activationScript = "${homeDir}/.local/state/nix/profiles/home-manager/activate";
        in
          nameValuePair "home-manager-activate-${userName}" {
            description = "Activate current Home Manager generation for ${userName}";
            wantedBy = ["multi-user.target"];

            after = ["local-fs.target"];
            unitConfig = {
              RequiresMountsFor = [
                "${homeDir}/.local/state/nix"
                "${homeDir}/.local/state/home-manager"
              ];
              ConditionPathExists = activationScript;
            };

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              User = userName;
              Group = "users";
              ExecStart = activationScript;
              Environment = [
                "HOME=${homeDir}"
                "USER=${userName}"
              ];
            };
          };
      in
        lib.listToAttrs (map mkHomeManagerActivation users);
    };
  };
}
