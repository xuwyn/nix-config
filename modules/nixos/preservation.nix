{
  modules.nixos.preservation = {
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
      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories =
            [
              "/etc"
              "/var"
              {
                directory = "/var/lib/nixos";
                inInitrd = true;
              }
              {
                directory = "/etc/sops";
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
              {
                file = "/etc/ssh/ssh_host_rsa_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_ed25519_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_rsa_key.pub";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_ed25519_key.pub";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/var/lib/systemd/random-seed";
                how = "symlink";
                inInitrd = true;
                configureParent = true;
              }
            ]
            ++ cfg.files;

          users = let
            defaultUserDirectories = [
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
              "nix-config" # TODO: mkOption for flakePath
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

      # Make btrfs snapshots
      boot.initrd.systemd.services.btrfs-root-rotate = {
        wantedBy = ["initrd.target"];
        after = ["systemd-cryptsetup@cryptroot.service"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs_tmp
          mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          rotate_subvolume() {
            local name="$1"
            local archiveDir="/btrfs_tmp/old_''${name}s"

            if [[ -e "/btrfs_tmp/$name" ]]; then
              mkdir -p "$archiveDir"
              local timestamp
              timestamp=$(date --date="@$(stat -c %Y "/btrfs_tmp/$name")" "+%Y-%m-%d_%H:%M:%S")
              mv "/btrfs_tmp/$name" "$archiveDir/$timestamp"
            fi

            for i in $(find "$archiveDir" -mindepth 1 -maxdepth 1 -mtime +10 2>/dev/null); do
              delete_subvolume_recursively "$i"
            done

            btrfs subvolume create "/btrfs_tmp/$name"
          }

          rotate_subvolume root
          rotate_subvolume home

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
