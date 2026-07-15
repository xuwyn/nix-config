{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    modules = mkOption {
      type = types.submodule {
        options = {
          nixos = mkOption {
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

    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
    };
  };
}
