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
    };
    imports = [inputs.niri-nix.homeModules.default];

    config = {
      wayland.windowManager.niri = {
        enable = true;
        package = pkgs.xwayland-satellite-unstable;
        systemd.variables = ["--all"];
        settings = {
          output = (
            map (m: {
              _args = [m.name];
              mode = "${toString m.width}x${toString m.height}@${toString m.refresh}";
              position._props = {
                x = m.x;
                y = m.y;
              };
              scale = 1;
            })
            config.homeManager.monitors
          );
        };
        extraConfig = '''';
      };
    };
  };
}
