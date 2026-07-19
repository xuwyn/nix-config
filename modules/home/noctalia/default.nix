{
  modules.homeManager.noctalia = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    qylockEnabled = config.homeManager.desktop.qylockEnabled or false;
  in {
    options.homeManager.noctalia._module_marker = lib.mkOption {
      type = lib.types.bool;
      default = true;
      readOnly = true;
      internal = true;
      visible = false;
      description = "Internal: marks that this module was imported. Do not set manually.";
    };

    imports = [inputs.noctalia.homeModules.default];

    config = {
      # Install the Noctalia package
      home.packages = [
        noctaliaPkg
        pkgs.evtest # read kb input for bongo cat
      ];

      home.file.".local/state/noctalia/settings.toml".source =
        mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nix-config/modules/home/noctalia/settings.toml";

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          idle = {
            behavior_order = ["qylock" "idle-behavior" "idle-behavior-2"];
            pre_action_fade_seconds = 0;
            behavior = {
              "qylock" = {
                action = "command";
                command = "qylock-lock";
                enabled = qylockEnabled;
                timeout = 600;
              };
              "idle-behavior" = {
                action = "lock";
                enabled = !qylockEnabled;
                timeout = 600;
              };
              "idle-behavior-2" = {
                action = "suspend";
                enabled = true;
                lock_before_suspend = false;
                timeout = 1200;
              };
            };
          };
          shell = {
            avatar_path = "${config.home.homeDirectory}/.face";
            font_family = "Maple Mono NF";
            date_format = "%A, %Y %b %d";
            launch_apps_as_systemd_services = true;
            settings_show_advanced = true;
            telemetry_enabled = false;

            panel = {
              control_center_placement = "floating";
              open_near_click_control_center = true;
              session_placement = "floating";
              session_position = "center";
              shadow = false;
              transparency_mode = "glass";
              wallpaper_placement = "floating";
            };

            screen_corners = {
              enabled = true;
              size = 40;
            };

            screenshot = {
              directory = "${config.home.homeDirectory}/Pictures/Screenshots";
            };

            session = {
              actions = [
                {
                  action = "command";
                  command = "qylock-lock";
                  enabled = qylockEnabled;
                  glyph = "lock";
                  label = "Lock";
                  shortcut = "1";
                  variant = "default";
                }
                {
                  action = "lock";
                  enabled = !qylockEnabled;
                  shortcut = "1";
                  variant = "default";
                }
                {
                  action = "logout";
                  enabled = true;
                  shortcut = "2";
                  variant = "default";
                }
                {
                  action = "command";
                  command = "qylock-lock & sleep 2 && systemctl suspend";
                  enabled = qylockEnabled;
                  glyph = "player-pause";
                  label = "Suspend";
                  shortcut = "3";
                  variant = "default";
                }
                {
                  action = "lock_and_suspend";
                  enabled = !qylockEnabled;
                  glyph = "player-pause";
                  label = "Suspend";
                  shortcut = "3";
                  variant = "default";
                }
                {
                  action = "command";
                  command = "systemctl reboot --firmware-setup";
                  enabled = true;
                  glyph = "cpu";
                  label = "BIOS Reboot";
                  shortcut = "4";
                  variant = "default";
                }
                {
                  action = "reboot";
                  enabled = true;
                  shortcut = "5";
                  variant = "default";
                }
                {
                  action = "shutdown";
                  enabled = true;
                  shortcut = "6";
                  variant = "destructive";
                }
              ];
            };

            shadow = {
              alpha = 0.0;
            };
          };
        };
      };
    };
  };
}
