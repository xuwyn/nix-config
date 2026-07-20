{
  modules.homeManager.niri = {
    config,
    lib,
    inputs,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.niri;
  in {
    options.homeManager.niri = {
      _module_marker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        readOnly = true;
        internal = true;
        visible = false;
        description = "Internal: marks that this module was imported. Do not set manually.";
      };
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {type = lib.types.str;}; # "DP-0"
            width = lib.mkOption {type = lib.types.int;};
            height = lib.mkOption {type = lib.types.int;};
            refresh = lib.mkOption {
              type = lib.types.int;
              default = 60;
            };
            x = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
            y = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
            primary = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        });
        default = [];
      };
    };
    imports = [inputs.niri-nix.homeModules.default];
    config = {
      wayland.windowManager.niri = {
        enable = true;
        package = pkgs.xwayland-satellite-unstable;
        settings = {
        };
        extraConfig = '''';
      };
    };
  };
}
