{
  modules.homeManager.umbriel = {
    config,
    lib,
    inputs,
    pkgs,
    flake,
    ...
  }: {
    options.homeManager.umbriel = {
      _module_marker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        readOnly = true;
        internal = true;
        visible = false;
        description = "Internal: marks that this module was imported. Do not set manually.";
      };
    };
    imports = [inputs.umbriel.homeModules.default];
    config = {
      programs.umbriel = {
        enable = true;
        settings = {
          environment = import ./_env.nix {inherit config;};
          animation = import ./_animation.nix;
          keybinds = import ./_binds.nix {inherit config lib;};
          window_rule = import ./_windowrules.nix;

          layer_rule = [
            {
              match.namespace = ''^noctalia-(bar-[^"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^"]*)$'';
              blur = true;
              blur_ignore_alpha = 0.5;
              blur_popups = true;
              blur_optimized = false;
            }
          ];

          include.files = ["noctalia.toml"];

          general = {
            autostart =
              [
                "noctalia &"
                "vellum &"
              ]
              ++ config.homeManager.desktop.startupCommands;
            mod_key = "Super"; # Force Super instead of nested-session Alt
            xwayland = true; # Requires xwayland-satellite; restart to change
            show_cheatsheet = false; # Show the keybind overlay on startup
          };

          workspaces = {
            back_and_forth = false; # Re-select active workspace to switch back
            empty_above = false; # Keep one empty workspace above active range
          };

          workspace = let
            kanjiNumerals = ["一" "二" "三" "四" "五"];
            mkWorkspace = n: {
              name = builtins.elemAt kanjiNumerals (n - 1);
            };
          in
            map mkWorkspace (builtins.genList (i: i + 1) 5);

          output = let
            kanjiNumerals = ["一" "二" "三" "四" "五"];
            mkOutput = monitor: {
              name = monitor.name;
              value = {
                enabled = true;
                mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refresh}";
                position = [monitor.x monitor.y];
                transform = "normal";
                vrr = "disabled";
                tearing = false;
                direct_scanout = true;
                hdr = "auto";
                workspaces = kanjiNumerals;
              };
            };
          in
            builtins.listToAttrs (map mkOutput config.homeManager.desktop.monitors);

          input = {
            middle_click_paste = true; # Primary-selection paste; applies on reload
            mouse = {
              natural_scroll = true;
              sensitivity = 0.0;
            };
            touchpad = {
              tap = true; # Tap-to-click
              natural_scroll = true; # Omit to preserve the libinput default
              accel_profile = "adaptive"; # flat, adaptive, or custom <step> <points...>
              # sensitivity = 0.5; # Pointer speed, -1.0 to 1.0
            };
            cursor = {
              theme = ""; # Empty uses environment or default Xcursor theme
              size = 24; # Logical size, 1-512
              hardware_cursor = true; # False forces cursor composition
              follows_focus = true; # Warp to windows selected by focus, output, move, or other activations
              hide_when_typing = false; # Keep visible while typing
              hide_timeout_ms = 0; # Idle hide timeout, 0 disables; maximum is 3600000
            };
            focus.follows_mouse = false; # Focus on pointer motion and Dwindle/master tiles revealed on close
          };

          appearance = {
            prefer_no_csd = true; # Prefer Umbriel's border-only decoration
            border_width = 3; # Inner border width, 0-100 logical pixels
            outer_border_width = 0; # Optional outer ring, 0-100 logical pixels
            corner_radius = 10; # Radius of the final decorated edge, 0-100
            drag_opacity = 0.75; # Window opacity during a tiled or floating drag
            blur = {
              enabled = true; # Disable blur and release per-output effect buffers
              optimized = true; # Reuse one cached background blur per output
              passes = 3; # Blur passes, 0-8
              radius = 3; # Blur radius, 0-100
              noise = 0.02; # Noise overlay, 0.0-1.0
              brightness = 0.9; # 0.0-2.0
              contrast = 0.9; # 0.0-2.0
              saturation = 1.1; # 0.0-2.0
            };
            shadow = {
              enabled = true; # Draw shadows behind non-fullscreen windows
              softness = 10; # Gaussian softness, 0-200; 0 is a hard edge
              offset_x = 2; # Horizontal offset, -200 to 200
              offset_y = 2; # Vertical offset, -200 to 200
            };
          };

          layout = {
            mode = "scrolling"; # scrolling, dwindle, or master
            gap = 8; # Logical pixels between tiles, 0-500
            width_presets = [0.333 0.5 0.667]; # Width and height cycling fractions
            struts = {
              left = 0; # -65535 to 65535
              right = 0;
              top = 0;
              bottom = 0;
            };
            scrolling = {
              # The strip axis is perpendicular to the output's workspace_axis.
              default_width_fraction = 0.5; # Initial width for new columns, 0.1-1.0
              center_underfull_strip = true; # Center a strip narrower than the viewport
            };
            dwindle = {
              # preserve_split = false; # Keep every split direction fixed after creation
            };
            master = {
              position = "left"; # left, right, or center master area
              default_width_fraction = 0.55; # Initial master area fraction, 0.1-0.9
              new_on_top = false; # Put new windows at the top of the stack
            };
          };

          overview = {
            zoom = 0.5; # Workspace scale in overview, 0.1-0.75
            shortcuts = false;
            # background_blur = true; # Blur the wallpaper behind overview rows
            # workspace_wallpaper = true; # Mirror wallpapers inside workspace previews
          };
        };
      };
    };
  };
}
