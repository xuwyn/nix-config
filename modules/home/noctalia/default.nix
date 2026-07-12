{
  modules.homeManager.noctalia = {
    pkgs,
    inputs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    noctaliaPkg = inputs.noctalia.packages.${system}.default;
    qylockEnable = config.homeManager.hyprland.qylock.enable or false;
  in {
    # Install the Noctalia package
    home.packages = [
      noctaliaPkg
      pkgs.matugen # color palette generator
      pkgs.evtest # read kb input for bongo cat
    ];

    home.file.".local/state/noctalia/settings.toml".source =
      mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/modules/home/noctalia/settings.toml";

    # Configure Noctalia via home module
    imports = [inputs.noctalia.homeModules.default];
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
              enabled = qylockEnable;
              timeout = 600;
            };
            "idle-behavior" = {
              action = "lock";
              enabled = !qylockEnable;
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
                enabled = qylockEnable;
                glyph = "lock";
                label = "Lock";
                shortcut = "1";
                variant = "default";
              }
              {
                action = "lock";
                enabled = !qylockEnable;
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
                enabled = qylockEnable;
                glyph = "player-pause";
                label = "Suspend";
                shortcut = "3";
                variant = "default";
              }
              {
                action = "lock_and_suspend";
                enabled = !qylockEnable;
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
}
