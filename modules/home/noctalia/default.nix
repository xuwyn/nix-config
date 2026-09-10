{
  modules.homeManager.noctalia = {
    pkgs,
    config,
    lib,
    flake,
    inputs,
    ...
  }: {
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
      home.packages = [pkgs.evtest]; # for bongocat
      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = true;
        settings = {
          bar.default = {
            background_opacity = 0.65;
            capsule = true;
            capsule_border = "primary";
            capsule_foreground = "primary";
            start = ["workspaces" "media" "audio_visualizer"];
            center = ["group:g3"];
            end = ["recorder" "todo" "nix-monitor" "group:g1" "group:g2"];
            font_family = "Maple Mono NF";
            margin_edge = 0;
            margin_ends = 20;
            padding = 6;
            panel_overlap = 0;
            radius = 20;
            radius_top_left = 8;
            radius_top_right = 8;
            shadow = false;
            capsule_group = [
              {
                border = "primary";
                enabled = true;
                fill = "surface_variant";
                foreground = "primary";
                id = "g1";
                members = ["temp" "cpu" "ram" "sysmon"];
                opacity = 1.0;
                padding = 6.0;
              }
              {
                border = "primary";
                enabled = true;
                fill = "surface_variant";
                foreground = "primary";
                id = "g2";
                members = ["network" "bluetooth"];
                opacity = 1.0;
                padding = 6.0;
              }
              {
                border = "primary";
                enabled = true;
                fill = "surface_variant";
                foreground = "primary";
                id = "g3";
                members = ["tray" "notifications" "clock" "cat"];
                opacity = 1.0;
                padding = 6.0;
              }
            ];
          };
          brightness.enable_ddcutil = true;
          control_center = {
            sidebar_section = "none";
            shortcuts = [
              {type = "wifi";}
              {type = "bluetooth";}
              {type = "dark_mode";}
              {type = "caffeine";}
              {type = "audio";}
              {type = "notification";}
            ];
          };
          dock = {
            auto_hide = true;
            background_opacity = 0.65;
            enabled = true;
            icon_size = 35;
            inactive_opacity = 0.60;
            item_spacing = 8;
            reserve_space = false;
            shadow = false;
            show_dots = true;
            show_instance_count = false;
          };
          idle = {
            behavior_order = ["lock" "screen-off" "lock-and-suspend"];
            behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 600.0;
              };
              "lock-and-suspend" = {
                action = "lock_and_suspend";
                enabled = false;
                timeout = 900.0;
              };
              "screen-off" = {
                action = "screen_off";
                enabled = false;
                timeout = 660.0;
              };
            };
          };
          keybinds.cancel = ["Delete" "Escape"];
          location.auto_locate = true;
          lockscreen.blur_intensity = 0.0;
          lockscreen_widgets = let
            monitorNames = map (m: m.name) config.homeManager.desktop.monitors;
            lockscreenLoginBox = {
              box_height = 196.0;
              box_width = 810.0;
              cx = 960.0;
              cy = 910.0;
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = true;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = false;
                show_weather = true;
              };
            };
            lockscreenAudioVisualizer = {
              box_height = 288.0;
              box_width = 816.0;
              cx = 960.0;
              cy = 668.0;
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "audio_visualizer";
              settings = {
                background = false;
                background_color = "surface";
                background_opacity = 0.80;
                background_padding = 10;
                background_radius = 12;
                bands = 52;
                centered = false;
                color_1 = "primary";
                color_2 = "primary";
                mirrored = true;
                reversed = false;
                show_when_idle = false;
              };
            };
            mkPerMonitorWidgets = prefix: base:
              lib.listToAttrs (map (name: {
                  name = "${prefix}@${name}";
                  value = base // {output = name;};
                })
                monitorNames);
          in {
            enabled = true;
            schema_version = 1;
            widget_order =
              (map (name: "lockscreen-login-box@${name}") monitorNames)
              ++ (map (name: "lockscreen-audio-visualizer@${name}") monitorNames);
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget =
              (mkPerMonitorWidgets "lockscreen-login-box" lockscreenLoginBox)
              // (mkPerMonitorWidgets "lockscreen-audio-visualizer" lockscreenAudioVisualizer);
          };
          plugin_settings = {
            "avivbintangaringga/nix-monitor" = {
              clean_command = "nh clean all";
              update_command = "cd ~/${flake.homeRelativePath} && tack update";
            };
            "noctalia/notes".panel_open_near_click = true;
            "yocraft/web-launcher" = {
              icon_provider = "duckduckgo";
              links = [
                "Noctalia|https://docs.noctalia.dev/v5/"
                "DankMaterialShell|https://danklinux.com/docs/"
                "GitHub|https://github.com"
                "GitLab|https://gitlab.com"
                "Codeberg|https://codeberg.org"
                "YouTube|https://youtube.com"
              ];
            };
          };
          plugins = {
            enabled = [
              "noctalia/screen_recorder"
              "noctalia/wallhaven"
              "noctalia/bongocat"
              "noctalia/notes"
              "noctalia/kaomoji"
              "noctalia/translator"
              "avivbintangaringga/nix-monitor"
              "nightwatch75/todo"
              "yocraft/web-launcher"
            ];
            source = [
              {
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
                name = "official";
              }
              {
                kind = "git";
                location = "https://github.com/noctalia-dev/community-plugins";
                name = "community";
              }
            ];
          };
          shell = {
            avatar_path = "${config.home.homeDirectory}/.face";
            screenshot.directory = "${config.home.homeDirectory}/Pictures/Screenshots";
            date_format = "%A, %Y %b %d";
            font_family = "Maple Mono NF";
            niri_overview_type_to_launch_enabled = true;
            password_style = "random";
            polkit_agent = true;
            screen_time_enabled = true;
            panel = {
              control_center_placement = "attached";
              open_near_click_control_center = true;
              session_placement = "floating";
              session_position = "center";
              transparency_mode = "glass";
              wallpaper_placement = "attached";
            };
            screen_corners = {
              enabled = true;
              size = 40;
            };
            session.actions = [
              {
                action = "lock";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "1";
                variant = "default";
              }
              {
                action = "logout";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "2";
                variant = "default";
              }
              {
                action = "lock_and_suspend";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "3";
                variant = "default";
              }
              {
                action = "reboot";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "4";
                variant = "default";
              }
              {
                action = "command";
                command = "systemctl reboot --firmware-setup";
                countdown_seconds = 0.0;
                enabled = true;
                glyph = "cpu";
                label = "UEFI Reboot";
                shortcut = "5";
                variant = "default";
              }
              {
                action = "shutdown";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "6";
                variant = "default";
              }
            ];
          };
          system.monitor = {
            cpu_poll_seconds = 1;
            network_poll_seconds = 1;
          };
          theme = {
            builtin = "Ayu";
            custom_palette = "m3-content";
            mode = "dark";
            source = "wallpaper";
            wallpaper_scheme = "m3-tonal-spot";
            templates = {
              builtin_ids = ["btop" "cava" "gtk3" "gtk4" "ghostty" "hyprland" "kitty" "niri" "qt"];
              community_ids = ["pywalfox" "discord" "zed"];
              user."nvim-base16" = {
                input_path = "~/.config/nvim/lua/matugen-template.lua";
                output_path = "~/.config/nvim/lua/matugen.lua";
                post_hook = "pkill -SIGUSR1 nvim";
              };
            };
          };
          wallpaper = {
            directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
            automation = {
              enabled = true;
              interval_seconds = 300;
            };
          };
          widget = {
            audio_visualizer = {
              centered = false;
              width = 100.0;
            };
            cat = {
              audio_spectrum = true;
              scale = 1.45;
              tappy_mode = true;
              type = "noctalia/bongocat:cat";
            };
            media = {
              hide_when_no_media = true;
              title_scroll = "always";
            };
            network.show_label = false;
            "nix-monitor" = {
              show_text = false;
              type = "avivbintangaringga/nix-monitor:nix-monitor";
            };
            recorder.type = "noctalia/screen_recorder:recorder";
            sysmon.stat = "disk_used_pct";
            todo.type = "nightwatch75/todo:todo";
            tray = {
              drawer = true;
              hidden = ["network" "blueman"];
            };
          };
        };
      };
    };
  };
}
