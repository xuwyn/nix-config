{
  host,
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  extraMonitorSettings = vars.extraMonitorSettings or "";
  keyboardLayout = vars.keyboardLayout or "us";
  keyboardVariant = vars.keyboardVariant or "";

  barChoice = vars.barChoice or "";
  barThemeEnable = vars.barThemeEnable or false;
  barThemes = {
    noctalia = builtins.readFile ../dotfiles/hypr/noctalia.lua;
  };

  # Treat only known US-based variants as implying layout = "us".
  usVariants = ["dvorak" "colemak" "workman" "intl" "us-intl" "altgr-intl"];
  normalizeUSVariant = v:
    if v == "us-intl"
    then "intl"
    else v;

  # If layout itself is a US variant (e.g., "dvorak", "us-intl"), normalize it
  layoutFromLayout =
    if builtins.elem keyboardLayout usVariants
    then "us"
    else keyboardLayout;
  variantFromLayout =
    if builtins.elem keyboardLayout usVariants
    then normalizeUSVariant keyboardLayout
    else "";

  # If the provided variant is a US variant, force layout to us; otherwise keep layout
  layoutFromVariant =
    if builtins.elem keyboardVariant usVariants
    then "us"
    else layoutFromLayout;
  variantFinal =
    if builtins.elem keyboardVariant usVariants
    then normalizeUSVariant keyboardVariant
    else if variantFromLayout != ""
    then variantFromLayout
    else keyboardVariant;

  hyprKbLayout = layoutFromVariant;
  hyprKbVariant = variantFinal;
in {
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../wallpapers;
      # recursive = true;
      force = true;
    };
    ".face".source = ./face.jpg;
  };
  xdg.configFile."hypr/hyprland.lua".force = true;
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    xwayland = {
      enable = true;
    };
    settings.config = {
      animations.enabled = true;
      input =
        {
          kb_layout = hyprKbLayout;
          kb_options = "grp:alt_caps_toggle";
          numlock_by_default = true;
          repeat_delay = 300;
          follow_mouse = 1;
          float_switch_override_focus = 0;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
          };
          natural_scroll = true;
        }
        // lib.optionalAttrs (hyprKbVariant != "") {kb_variant = hyprKbVariant;};

      cursor = {
        enable_hyprcursor = false;
        no_hardware_cursors = 2;
        no_warps = true;
        sync_gsettings_theme = true;
        warp_on_change_workspace = 2;
      };

      gestures = {
        workspace_swipe_distance = 500;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = true;
      };

      scrolling = {
        column_width = 0.80;
        fullscreen_on_one_column = true;
        direction = "right";
        follow_focus = true;
      };

      monocle = {};

      general =
        {
          layout = "dwindle";
          gaps_in = 5;
          gaps_out = 10;
          border_size = 3;
          resize_on_border = true;
        }
        // lib.optionalAttrs (!barThemeEnable) {
          "col.active_border" = "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
          "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
        };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vrr = 0;

        #  Application not responding (ANR) settings
        enable_anr_dialog = true;
        anr_missed_pings = 15;
      };

      dwindle = {
        preserve_split = true;
        smart_resizing = true;
        use_active_for_splits = true;
        smart_split = false;
        default_split_ratio = 1.0;
        split_bias = 0;
        precise_mouse_move = false;
        special_scale_factor = 0.8;
      };

      decoration = {
        blur = {
          enabled = true;
          ignore_opacity = false;
          new_optimizations = true;
          passes = 2;
          size = 3;
          vibrancy = 0.169600;
        };
        shadow = {
          color = "rgba(ee1a1a1a)";
          enabled = true;
          range = 4;
          render_power = 3;
        };
        rounding = 10;
        rounding_power = 2;
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      render = {
        # Disabling as no longer supported
        #explicit_sync = 1; # Change to 1 to disable
        #explicit_sync_kms = 1;
        direct_scanout = 0;
      };

      master = {
        new_status = "slave";
        new_on_top = false;
        new_on_active = "none";
        orientation = "left";
        mfact = 0.55;
        slave_count_for_center_master = 2;
        center_master_fallback = "left";
        smart_resizing = true;
        drop_at_cursor = true;
        always_keep_position = false;
      };

      # Ensure Xwayland windows render at integer scale; compositor scales them
      xwayland = {
        force_zero_scaling = true;
      };
    };

    extraConfig = ''
      local modifier = "SUPER"

      hl.gesture({
          fingers = 3,
          direction = "horizontal",
          action = "workspace",
      })

      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = "auto",
      })

      hl.monitor({
        output = "Virtual-1",
        mode = "1920x1080@60",
        position = "auto",
        scale = 1,
      })

      ${lib.optionalString (extraMonitorSettings != "") extraMonitorSettings}

      -- Persistent Workspaces 1-5
      hl.workspace_rule({
          workspace = "1",
          persistent = true,
      })

      hl.workspace_rule({
          workspace = "2",
          persistent = true,
      })

      hl.workspace_rule({
          workspace = "3",
          persistent = true,
      })

      hl.workspace_rule({
          workspace = "4",
          persistent = true,
      })

      hl.workspace_rule({
          workspace = "5",
          persistent = true,
      })

      -- Noctalia Blur
      hl.layer_rule({
        name = "noctalia",
        match = {
          namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
        },
        no_anim = true,
        ignore_alpha = 0.5,
        blur = true,
        blur_popups = true,
      })

      ${lib.optionalString barThemeEnable (barThemes.${barChoice} or "")}
    '';
  };
}
