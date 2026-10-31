{
  monitors,
  lib,
}: {
  bar.default = {
    background_opacity = 1;
    capsule = true;
    capsule_border_width = 0.0;
    capsule_opacity = 0.0;
    capsule_border = "primary";
    capsule_foreground = "primary";
    start = ["group:g4" "group:g5"];
    center = ["group:g8" "group:g6" "group:g7"];
    end = ["bracket_left" "group:g9" "bracket_right" "group:g3" "group:g1" "group:g2"];
    font_family = "Maple Mono NF";
    margin_edge = 0;
    margin_ends = 0;
    padding = 15;
    panel_overlap = 0;
    radius = 20;
    radius_bottom_left = 10;
    radius_bottom_right = 10;
    radius_top_left = 0;
    radius_top_right = 0;
    shadow = false;
    thickness = 32;
    capsule_group = let
      group = id: members: {
        inherit id members;
        accordion = false;
        accordion_direction = "end";
        border = "primary";
        border_width = 0.0;
        enabled = true;
        fill = "surface_container";
        foreground = "primary";
        opacity = 0.0;
        padding = 0.0;
      };
    in [
      (group "g1" [
        "bracket_left"
        "temp"
        "slash"
        "cpu"
        "slash"
        "ram"
        "slash"
        "sysmon"
        "bracket_right"
      ])
      (group "g2" ["bracket_left" "network" "bluetooth" "bracket_right"])
      (group "g3" ["bracket_left" "nix-monitor" "bracket_right"])
      (group "g4" ["bracket_left" "workspaces" "bracket_right"])
      (group "g5" ["bracket_left" "radio" "media" "bracket_right"])
      (group "g6" ["bracket_left" "cat_2" "clock" "cat" "bracket_right"])
      (group "g7" ["bracket_left" "audio_visualizer" "bracket_right"])
      (group "g8" ["bracket_left" "audio_visualizer" "bracket_right"])
      ((group "g9" [
          "launcher"
          "slash"
          "recorder"
          "slash"
          "notifications"
          "slash"
          "tray"
        ])
        // {accordion = true;})
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
        background_color = "surface_container";
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
        monitors);
  in {
    enabled = true;
    schema_version = 1;
    widget_order =
      (map (name: "lockscreen-login-box@${name}") monitors)
      ++ (map (name: "lockscreen-audio-visualizer@${name}") monitors);
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
    "noctalia/screen_recorder".video_encoder = "cpu"; # nvidia driver is a bit behind
    "avivbintangaringga/nix-monitor" = {
      clean_command = "nh clean all";
    };
    "noctalia/notes".panel_open_near_click = true;
    "yocraft/web-launcher" = {
      icon_provider = "duckduckgo";
      links = [
        "Umbriel|https://docs.noctalia.dev/umbriel/"
        "UmbrielGit|https://github.com/noctalia-dev/umbriel"
        "Noctalia|https://docs.noctalia.dev/noctalia/"
        "NoctaliaGit|https://github.com/noctalia-dev/noctalia"
        "GitHub|https://github.com"
        "GitLab|https://gitlab.com"
        "YouTube|https://youtube.com"
      ];
    };
  };
  plugins = {
    enabled = [
      "noctalia/screen_recorder"
      "noctalia/bongocat"
      "noctalia/notes"
      "noctalia/kaomoji"
      "noctalia/translator"
      "avivbintangaringga/nix-monitor"
      "nightwatch75/todo"
      "yocraft/web-launcher"
      "noctalia/world_clock"
      "nilsonlinux/world-radio"
      "ashur-d/wallpaper-widget"
      "rylos/tailnet"
      "srounce/systemd"
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
    window_switcher = {
      mru = true;
      show_caption = false;
    };
    launcher = {
      category_icons_only = true;
      layout = "full";
      show_navigation_labels = false;
    };
    umbriel_overview_type_to_launch_enabled = true;
    avatar_path = "~/.face";
    screenshot.directory = "~/Pictures/Screenshots";
    date_format = "%A, %Y %b %d";
    font_family = "Maple Mono NF";
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
      size = 20;
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
  notification = {
    filter_order = ["no_sound"];
    filter.no_sound = {
      enabled = true;
      match_content = ".*";
      show_toast = true;
      save_history = true;
      play_sound = false;
    };
  };
  theme = {
    mode = "dark";
    source = "wallpaper";
    wallpaper_scheme = "faithful";
    templates = {
      builtin_ids = ["btop" "cava" "gtk3" "gtk4" "helix" "ghostty" "kitty" "umbriel" "qt"];
      community_ids = ["yazi" "sonora" "pywalfox" "discord" "zed" "neovim" "papirus-icons"];
    };
  };
  wallpaper = {
    directory = "~/Pictures/Wallpapers";
    automation = {
      enabled = true;
      interval_seconds = 300;
    };
  };
  widget = let
    noPadding = {capsule_padding = 0;};
  in {
    audio_visualizer =
      noPadding
      // {
        width = 100;
        centered = true;
        show_when_idle = true;
      };
    bluetooth = noPadding;
    bracket_left =
      noPadding
      // {
        text = "[";
        type = "text";
      };
    bracket_right =
      noPadding
      // {
        text = "]";
        type = "text";
      };
    slash =
      noPadding
      // {
        text = "/";
        type = "text";
      };
    cat =
      noPadding
      // {
        audio_spectrum = true;
        scale = 1.3;
        tappy_mode = true;
        type = "noctalia/bongocat:cat";
      };
    cat_2 =
      noPadding
      // {
        audio_spectrum = true;
        scale = 1.3;
        tappy_mode = true;
        type = "noctalia/bongocat:cat";
      };
    clock = noPadding;
    cpu =
      noPadding
      // {
        label_show_units = false;
        show_value = false;
      };
    launcher = noPadding;
    media =
      noPadding
      // {
        hide_album_art = true;
        max_length = 150;
        hide_when_no_media = true;
        title_scroll = "always";
      };
    network = noPadding // {show_label = false;};
    nix-monitor =
      noPadding
      // {
        show_text = false;
        type = "avivbintangaringga/nix-monitor:nix-monitor";
      };
    radio = noPadding // {type = "nilsonlinux/world-radio:radio";};
    recorder = noPadding // {type = "noctalia/screen_recorder:recorder";};
    ram = noPadding // {show_value = false;};
    sysmon =
      noPadding
      // {
        show_value = false;
        stat = "disk_used_pct";
      };
    temp =
      noPadding
      // {
        label_show_units = false;
        show_value = false;
      };
    tray =
      noPadding
      // {
        drawer = true;
        hidden = ["network" "blueman"];
      };
    workspaces =
      noPadding
      // {
        font_weight = 600;
        style = "minimal";
      };
  };
}
