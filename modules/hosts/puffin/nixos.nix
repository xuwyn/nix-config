{
  config,
  inputs,
  self,
  ...
}: let
  username = "wyn";
in {
  nixos-rpi.puffin = {lib, ...}: {
    users = [username "deploy"];
    modules = with config.modules.nixos;
      [rpi5 nix-settings network system users sops tailscale deploy services attic zram]
      ++ [
        inputs.home-manager.nixosModules.home-manager
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

          nixos = {
            users = {
              ${username} = {
                isAdmin = true;
                sshKeys = [../../common/keys/openssh_key.pub];
              };
              deploy = {
                isDeployer = true;
                sshKeys = [../../common/keys/deploy_key.pub];
              };
            };
            services.atticd = {
              enable = true;
              device = "/dev/disk/by-label/cache";
              tailscaleDomain = "puffin.tail9fb2b9.ts.net";
            };
          };

          sops.secrets.openssh_key = {
            sopsFile = ../../common/sops/ssh.yaml;
            owner = username;
          };

          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs self username;
              inherit (config) flake;
            };
            users.${username} = {osConfig, ...}: {
              # use inputs.nixpkgs instead of nixpkgs from nixos-raspberrypi
              _module.args = {
                pkgs = lib.mkForce (import inputs.nixpkgs {
                  system = "aarch64-linux";
                  config.allowUnfree = true;
                });
                lib = lib.mkForce inputs.nixpkgs.lib;
              };

              imports = with config.modules.homeManager;
                [home ssh cli]
                ++ [
                  {
                    # not using homeManager.sops cause I dont want to use rs-key here
                    options.sops.secrets = lib.mkOption {
                      type = lib.types.attrsOf (lib.types.submodule {
                        freeformType = lib.types.attrsOf lib.types.anything;
                        options.path = lib.mkOption {type = lib.types.str;};
                      });
                    };
                  }
                ];

              # point to sops.secrets from nixos so home modules can find them
              sops.secrets =
                lib.genAttrs ["openssh_key"]
                (name: {path = osConfig.sops.secrets.${name}.path;});

              homeManager = {
                ssh.hosts = {
                  apricot = {};
                  mango = {};
                  capybara = {};
                  "apricot.local" = {};
                  "mango.local" = {};
                  "capybara.local" = {};
                };
                cli = {
                  zsh.enable = true;
                  bash.enable = true;
                  tealdeer.enable = true;
                  search.enable = true;
                };
              };
            };
          };
        }
      ];
  };
}
