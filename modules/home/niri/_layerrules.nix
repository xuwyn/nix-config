{
  wayland.windowManager.niri.settings.layer-rule = [
    {
      match._props.namespace._raw = ''r#"^noctalia-wallpaper"#'';
      place-within-backdrop = true;
    }
    {
      match._props.namespace._raw = ''r#"^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"#'';
      background-effect = {
        xray = false;
        # blur = false; # uncomment this for transparent no-blur
      };
    }
    {
      match._props.namespace._raw = ''r#"noctalia-window-switcher"#'';
      background-effect = {
        blur = true;
        xray = false;
      };
    }
  ];
}
