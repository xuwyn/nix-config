{
  inputs,
  lib,
  config,
  self,
  ...
}: let
  overlays = import ../_overlays {inherit inputs;};
in {
  config = {
    nixosConfigurations =
      (lib.mapAttrs (
          name: cfg:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs self;
                inherit (cfg) host users;
                inherit (config) flake;
              };
              modules =
                cfg.modules
                ++ [
                  (_: {
                    nixpkgs = {
                      inherit overlays;
                      hostPlatform = cfg.system;
                      config.allowUnfree = true;
                    };
                  })
                ];
            }
        )
        config.nixos)
      // (lib.mapAttrs (
          name: cfg:
            inputs.nixos-raspberrypi.lib.nixosSystem {
              specialArgs = {
                inherit inputs self;
                inherit (cfg) host users;
                inherit (config) flake;
              };
              modules =
                cfg.modules
                ++ [
                  (_: {
                    nixpkgs = {
                      hostPlatform = cfg.system;
                      config.allowUnfree = true;
                    };
                  })
                ];
            }
        )
        config.nixos-rpi);

    darwinConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.nix-darwin.lib.darwinSystem {
            inherit (cfg) system;
            specialArgs = {
              inherit inputs self;
              inherit (cfg) host users;
              inherit (config) flake;
            };
            modules =
              cfg.modules
              ++ [
                (_: {
                  nixpkgs = {
                    inherit overlays;
                    config.allowUnfree = true;
                  };
                })
              ];
          }
      )
      config.darwin;

    homeConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              inherit (cfg) system;
              inherit overlays;
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs self;
              inherit (cfg) system username;
              inherit (config) flake;
            };
            modules = cfg.modules ++ [(_: {nixpkgs.config.allowUnfree = true;})];
          }
      )
      config.home;
  };
}
