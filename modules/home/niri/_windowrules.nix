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
