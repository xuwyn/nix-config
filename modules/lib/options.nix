{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    # Set flake constants applied to all modules
    flake = {
      homeRelativePath = mkOption {
        type = types.str;
        default = "nix-config";
        description = ''
          Path to flake dir relative to $HOME
          e.g. "nix-config" or ".config/nix-config"
        '';
      };
      name = mkOption {
        type = types.str;
        readOnly = true;
        default = baseNameOf config.homeRelativePath;
        description = "Flake directory name, derived from flake.homeRelativePath";
      };
    };

    modules = mkOption {
      type = types.submodule {
        options = {
          nixos = mkOption {
            type = types.lazyAttrsOf types.deferredModule;
            default = {};
          };
          darwin = mkOption {
            type = types.lazyAttrsOf types.deferredModule;
            default = {};
          };
          homeManager = mkOption {
            type = types.lazyAttrsOf types.deferredModule;
            default = {};
          };
        };
      };
      default = {};
    };

    nixos = mkOption {
      type = types.lazyAttrsOf (types.submodule ({name, ...}: {
        options = {
          host = mkOption {
            type = types.str;
            default = name;
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          users = mkOption {type = types.listOf types.str;};
          system = mkOption {
            type = types.str;
            default = "x86_64-linux";
          };
        };
      }));
      default = {};
    };

    nixos-rpi = mkOption {
      type = types.lazyAttrsOf (types.submodule ({name, ...}: {
        options = {
          host = mkOption {
            type = types.str;
            default = name;
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          users = mkOption {type = types.listOf types.str;};
          system = mkOption {
            type = types.str;
            default = "aarch64-linux";
          };
        };
      }));
      default = {};
    };

    darwin = mkOption {
      type = types.lazyAttrsOf (types.submodule ({name, ...}: {
        options = {
          host = mkOption {
            type = types.str;
            default = name;
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          users = mkOption {type = types.listOf types.str;};
          system = mkOption {
            type = types.str;
            default = "aarch64-darwin";
          };
        };
      }));
      default = {};
    };

    home = mkOption {
      type = types.lazyAttrsOf (types.submodule ({name, ...}: {
        options = {
          system = mkOption {type = types.str;};
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          username = mkOption {type = types.str;};
        };
      }));
      default = {};
    };

    nixosConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
    };

    darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
    };

    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
    };
  };
}
