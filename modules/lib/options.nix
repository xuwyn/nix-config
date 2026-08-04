{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    flake = mkOption {
      type = types.submodule ({config, ...}: {
        options = {
          homeRelativePath = mkOption {
            type = types.str;
            default = "nix-config";
            description = ''
              Path to flake dir relative to $HOME
              e.g. "nix-config" or ".config/nix-config"
            '';
          };
          dirName = mkOption {
            type = types.str;
            readOnly = true;
            default = baseNameOf config.homeRelativePath;
            description = "Flake directory name, derived from flake.homeRelativePath";
          };
        };
      });
      default = {};
      description = "Global constants for nixos and homeManager";
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
          system = mkOption {type = types.str;};
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
