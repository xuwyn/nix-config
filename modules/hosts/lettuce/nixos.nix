{
  config,
  inputs,
  self,
  ...
}: let
  wallpaper = ../../../assets/wallpapers/IS-Mysterious_Banquet.png;
  username = "wyn";
in {
  nixos.lettuce = {lib, ...}: {
    users = [username "deploy"];
    modules =
      (with config.modules.nixos; [wsl nix-settings sops system network attic tailscale users deploy])
      ++ [
        inputs.home-manager.nixosModules.home-manager
        {
          nixos.users = {
            ${username} = {
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

          sops.secrets =
            lib.mapAttrs (name: sopsFile: {
              inherit sopsFile;
              owner = username;
            }) {
              openssh_key = ../../common/sops/ssh.yaml;
              public_ssh_key = ../../common/sops/ssh.yaml;
              private_ssh_key = ../../common/sops/ssh.yaml;
              attic_token = ../../common/sops/access-tokens.yaml;
            };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            overwriteBackup = true;
            extraSpecialArgs = {
              inherit inputs self username;
              inherit (config) flake;
            };
            users.${username} = {osConfig, ...}: {
              imports = with config.modules.homeManager;
                [home yazi cli editors theme ssh attic]
                ++ [
                  {
                    # not using homeManager.sops cause I dont want to use rs-key on WSL
                    options.sops = lib.mkOption {
                      type = lib.types.submodule {
                        freeformType = lib.types.attrsOf lib.types.anything;
                      };
                    };
                  }
                ];
              # point config.sops to osConfig.sops
              sops = {inherit (osConfig.sops) secrets placeholder;};

              homeManager = {
                ssh.hosts = {
                  apricot = {};
                  puffin = {};
                  "apricot.local" = {};
                  "puffin.local" = {};
                };
                cli = {
                  bash.enable = true;
                  git = {
                    enable = true;
                    inherit username;
                    email = "173407133+xuwyn@users.noreply.github.com";
                  };
                  btop.enable = true;
                  nh.enable = true;
                  tealdeer.enable = true;
                  nix-search-tv.enable = true;
                  television.enable = true;
                  search.enable = true;
                  styling.enable = true;
                  utils.enable = true;
                };
                editors = {
                  nano.enable = true;
                  nixvim.enable = true;
                };
                theme.matugen = {
                  enable = true;
                  inherit wallpaper;
                  cachedThemeFile = ./_theme.json;
                };
              };
            };
          };
        }
      ];
  };
}
