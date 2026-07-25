{
  wayland.windowManager.niri.settings.window-rule = [
    {
      draw-border-with-background = false;
      open-maximized-to-edges = false;
      geometry-corner-radius = 15;
      clip-to-geometry = true;
      background-effect = {
        blur = true;
        xray = false;
      };
    }
    {
      match._props.app-id._raw = ''r#"^dev\.noctalia\.Noctalia$"#'';
      open-floating = true;
      default-column-width.fixed = 1080;
      default-window-height.fixed = 920;
    }
    {
      match._props.app-id._raw = ''r#"^org\.quickshell$"#'';
      open-floating = true;
    }
    {
      match._props.title._raw = ''r#"^(Picture-in-Picture)$"#'';
      open-floating = true;
      default-column-width.fixed = 426;
      default-window-height.fixed = 240;
    }
    {
      match._props.title._raw = ''r#"^(Waydroid)$"#'';
      open-floating = true;
    }
    {
      match._props.app-id._raw = ''r#"^(com\.jaoushingan\.WaydroidHelper)$"#'';
      open-floating = true;
    }
    {
      match._props.app-id._raw = ''r#"^(waydroid\.com\.YoStarEN\.Arknights)$"#'';
      open-floating = true;
    }
    {
      match._props.app-id._raw = ''r#"^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"#'';
      open-floating = true;
    }
    {
      match._props = {
        app-id._raw = ''r#"^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$"#'';
        is-active = true;
      };
      opacity = 0.90;
    }
    {
      match._props = {
        app-id._raw = ''r#"^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$"#'';
        is-active = false;
      };
      opacity = 0.80;
    }
  ];
}
