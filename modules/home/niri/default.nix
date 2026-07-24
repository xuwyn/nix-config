{
  modules.homeManager.niri = {
    config,
    lib,
    inputs,
    pkgs,
    ...
  }: {
    options.homeManager.niri = {
      _module_marker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        readOnly = true;
        internal = true;
        visible = false;
        description = "Internal: marks that this module was imported. Do not set manually.";
      };
      barThemeEnabled = lib.mkOption {
        type = lib.types.bool;
        default = config.homeManager.desktop.barThemeEnabled or false;
      };
    };
    imports = [
      inputs.niri-nix.homeModules.default
      ./_layerrules.nix
      ./_windowrules.nix
      ./_binds.nix
      ./_startup.nix
      ./_packages.nix
      ./_colors.nix
      ./_env.nix
    ];

    config = {
      wayland.windowManager.niri = {
        enable = true;
        package = null; # install via nixos
        validation.enable = false;
        systemd.variables = ["--all"];
        settings = {
          xwayland-satellite = {path = lib.getExe pkgs.xwayland-satellite;};
          input = {
            touchpad = {natural-scroll = [];};
            mouse = {natural-scroll = [];};
          };
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
            config.homeManager.desktop.monitors
          );
          workspace = lib.flatten (
            lib.imap0 (
              i: m:
                map (n: {
                  _args = [(toString (i * 5 + n))];
                  open-on-output = m.name;
                })
                (lib.range 1 5)
            )
            config.homeManager.desktop.monitors
          );
          debug = {honor-xdg-activation-with-invalid-serial = [];};
          overview = {workspace-shadow = {off = [];};};
          hotkey-overlay = {skip-at-startup = [];};
          clipboard = {disable-primary = [];};
          gestures = {hot-corners = {off = [];};};
          prefer-no-csd = true;
          layout = {
            background-color = "transparent";
            gaps = 8;
            struts = {
              left = 8;
              right = 8;
              top = 3;
              bottom = 3;
            };
            focus-ring = {
              width = 3;
            };
            border = {off = [];};
            default-column-width = {
              proportion = 0.5;
            };
            preset-column-widths._children = [
              {proportion = 0.33333;}
              {proportion = 0.5;}
              {proportion = 0.66667;}
              {proportion = 1.0;}
            ];
            preset-window-heights._children = [
              {proportion = 0.33333;}
              {proportion = 0.5;}
              {proportion = 0.66667;}
              {proportion = 1.0;}
            ];
            center-focused-column = "never";
            always-center-single-column = [];
          };
          blur = {
            passes = 2;
            offset = 3.0;
            noise = 0.03;
            saturation = 1.0;
          };
        };
      };
    };
  };
}
