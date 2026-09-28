[
  {
    blur = true;
    blur_optimized = false;
  }
  {
    match.is_alone = true;
    default_maximize = true;
  }
  {
    match.app_id = "^dev.noctalia.Noctalia$";
    default_floating = true;
    default_floating_size_px = {
      width = 1020;
      height = 900;
    };
  }
  {
    match.app_id = "^dev.noctalia.UmbrielSharePicker$";
    default_floating = true;
    default_floating_size_px = {
      width = 800;
      height = 600;
    };
  }
  {
    match.title = "^(Picture-in-Picture|Picture in picture)$";
    default_floating = true;
    default_maximize = false;
    default_floating_size_px = {
      width = 426;
      height = 240;
    };
    default_position = {
      x = 20;
      y = 20;
      anchor = "bottom_right";
    };
  }
  {
    match.title = ''^([Bb]top)$'';
    default_floating = true;
    default_floating_size_px = {
      width = 942;
      height = 800;
    };
    default_position = {
      x = 0;
      y = 0;
      anchor = "center";
    };
  }
  {
    match.title = ''^([Yy]azi)$'';
    default_floating = true;
    default_floating_size_px = {
      width = 942;
      height = 709;
    };
    default_position = {
      x = 0;
      y = 0;
      anchor = "center";
    };
  }
  {
    match.title = "^notificationtoasts_.+_desktop";
    default_position = {
      x = 20;
      y = 20;
      anchor = "bottom_right";
    };
    default_focused = false;
    default_pinned = true;
  }
  {
    match.app_id = ''^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$'';
    default_floating = true;
  }
  {
    match.app_id = ''^steam_app_\d+$'';
    default_floating = true;
  }
  {
    match.app_id = ''^([Ss]team)$'';
    default_floating = false;
  }
  {
    match.app_id = ''^(gamescope)$'';
    default_floating = true;
  }
  {
    match.app_id = ''^(Waydroid)$'';
    default_maximize = false;
    default_floating = false;
    default_floating_size_px = {
      width = 1600;
      height = 900;
    };
  }
  {
    match.app_id = ''^(com\.jaoushingan\.WaydroidHelper)$'';
    default_floating = true;
  }
  {
    match.app_id = ''^(waydroid\.com\.YoStarEN\.Arknights)$'';
    default_maximize = false;
    default_floating = false;
    default_floating_size_px = {
      width = 1600;
      height = 900;
    };
  }
  {
    match.app_id = ''^(xdg-desktop-portal-gtk)$'';
    default_floating = true;
    default_floating_size_px = {
      width = 764;
      height = 489;
    };
    opacity = 0.90;
  }
  {
    match = {
      app_id = ''^([Tt]hunar)$'';
      is_focused = true;
    };
    opacity = 0.90;
  }
  {
    match = {
      app_id = ''^([Tt]hunar)$'';
      is_focused = false;
    };
    opacity = 0.80;
  }
  {
    match = {
      app_id = ''^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$'';
      is_focused = true;
    };
    opacity = 0.90;
  }
  {
    match = {
      app_id = ''^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$'';
      is_focused = false;
    };
    opacity = 0.80;
  }
]
