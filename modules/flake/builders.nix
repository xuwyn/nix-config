{
  inputs,
  lib,
  config,
  ...
}: let
  overlays = import ../_overlays {inherit inputs;};
in {
  options = {
    nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule ({name, ...}: {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
            modules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [];
            };
            username = lib.mkOption {type = lib.types.str;};
            profile = lib.mkOption {type = lib.types.str;};
          };
        })
      );
      default = {};
    };
    home = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule ({name, ...}: {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
            system = lib.mkOption {type = lib.types.str;};
            modules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [];
            };
            username = lib.mkOption {type = lib.types.str;};
          };
        })
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
              inherit (cfg) host username profile;
            };
            modules = cfg.modules ++ [config.flake.modules.nixos.${cfg.profile}];
          }
      )
      config.nixos;
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
              inherit inputs;
              inherit (cfg) host username;
            };
            modules = cfg.modules;
          }
      )
      config.home;
  };
}
