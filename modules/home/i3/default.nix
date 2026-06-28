{
  flake.modules.homeManager.i3 = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.i3;
  in {
    options.homeManager.i3 = {
      enable = lib.mkEnableOption "Enable i3";
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The output name of the monitor (e.g., DP-2, HDMI-A-1).";
            };
            refreshRate = lib.mkOption {
              type = lib.types.str;
              default = "60";
              description = "The refresh rate as a string.";
            };
            workspaces = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "List of workspace IDs assigned to this monitor.";
            };
          };
        });
        default = [];
        description = "List of monitor configurations.";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "kitty";
        description = "Choose default terminal";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "Choose default browser";
      };
      background = lib.mkOption {
        type = lib.types.path;
        default = ../../../wallpapers/voyager.png;
        description = "Choose background";
      };
    };
    imports = [
      ./_binds.nix
      ./_windowcommands.nix
      ./_startup.nix
      ./_packages.nix
      ./_scripts
    ];
    config = let
      workspaceAssignments = builtins.concatLists (
        builtins.map (m:
          builtins.map (ws: {
            workspace = ws;
            output = m.name;
          })
          m.workspaces)
        cfg.monitors
      );
    in
      lib.mkIf cfg.enable {
        xsession.windowManager.i3 = {
          enable = true;
          package = pkgs.i3;

          config = {
            bars = [];

            # Remove title bars for all windows
            window = {
              border = 1;
              titlebar = false;
            };

            floating = {
              border = 1;
              titlebar = false;
            };

            gaps = {
              inner = 6;
              outer = 10;
            };

            # Assign workspaces to specific monitor
            workspaceOutputAssign = workspaceAssignments;
          };

          extraConfig = ''
            default_border pixel 1
            for_window [class=".*"] border pixel 1
            title_align center
          '';
        };
      };
  };
}
