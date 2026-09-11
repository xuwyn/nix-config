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
            };
            deploy = {
              isDeployer = true;
              sshKeys = [../../common/keys/deploy_key.pub];
            };
          };

          sops.secrets =
            lib.genAttrs ["openssh_key" "public_ssh_key" "private_ssh_key"]
            (name: {
              sopsFile = ../../common/sops/ssh.yaml;
              owner = username;
            });

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs self username;
              inherit (config) flake;
            };
            users.${username} = {osConfig, ...}: {
              imports = with config.modules.homeManager;
                [home yazi cli editors theme ssh]
                ++ [
                  {
                    # not using homeManager.sops cause I dont want to use rs-key on WSL
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
                lib.genAttrs ["openssh_key" "public_ssh_key" "private_ssh_key"]
                (name: {path = osConfig.sops.secrets.${name}.path;});

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
