{
  inputs,
  lib,
  config,
  ...
}: let
  overlays = import ../../overlays {inherit inputs;};
in {
  options = {
    nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options = {
            modules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [];
            };
            username = lib.mkOption {type = lib.types.str;};
            profile = lib.mkOption {type = lib.types.str;};
          };
        }
      );
      default = {};
    };

    home = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options = {
            system = lib.mkOption {type = lib.types.str;};
            modules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [];
            };
            username = lib.mkOption {type = lib.types.str;};
          };
        }
      );
      default = {};
    };
  };

  config.flake = {
    nixosConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs overlays;
              host = name;
              inherit (cfg) username profile;
            };
            modules = cfg.modules;
          }
      )
      config.nixos;

    homeConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              inherit (cfg) system overlays;
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs;
              host = name;
              inherit (cfg) username;
            };
            modules = cfg.modules;
          }
      )
      config.home;
  };
}
