{
  wayland.windowManager.hyprland = {
    settings.window_rule = [
      {
        match.class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";
        opacity = "1.0 0.9";
        no_blur = false;
      }
      {
        match.title = "^(Picture-in-Picture|Picture in picture)$";
        float = true;
        keep_aspect_ratio = true;
        opacity = "0.95 0.75";
        size = ["30%" "30%"];
        move = ["monitor_w - window_w - 20" "monitor_h - window_h - 20"];
      }
      {
        match.class = "^(zed|dev\\.zed\\.Zed|Zed)$";
        opacity = "0.90 0.80";
        no_blur = false;
      }
      {
        match.class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$";
        size = ["monitor_w * 0.5" "monitor_h * 0.6"];
        opacity = "0.95 0.85";
        no_blur = false;
        float = true;
        center = true;
      }
      {
        match.class = "^(Waydroid)$";
        float = true;
      }
      {
        match.class = "^(com\\.jaoushingan\\.WaydroidHelper)$";
        float = true;
      }
      {
        match.class = "^(waydroid\\.com\\.YoStarEN\\.Arknights)$";
        float = true;
      }
      {
        match.class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$";
        opacity = "0.93 0.85";
        no_blur = false;
      }
      {
        match.class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$";
        opacity = "0.94 0.86";
      }
      {
        match.class = "^(gamescope)$";
        no_blur = true;
        fullscreen = true;
      }
      {
        match.class = "^steam_app_\\d+$";
        no_blur = true;
        fullscreen = true;
      }
      {
        match.class = "^([Ss]team)$";
        float = true;
      }
      {
        match.class = "^(file-roller|org.gnome.FileRoller)$";
        float = true;
        opacity = "0.95 0.85";
        size = ["70%" "70%"];
        no_blur = false;
      }
      {
        match.class = "^(nm-applet|nm-connection-editor|blueman-manager)$";
        float = true;
        opacity = "0.95 0.85";
        size = ["70%" "70%"];
        no_blur = false;
      }
      {
        match.title = "^(Authentication Required)$";
        center = true;
        float = true;
      }
    ];
    extraConfig = ''
      hl.on("window.title", function(w)
        if w.title and w.title:match("^([Yy]azi:.*)$") then
          if not w.floating then
            hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
            hl.dispatch(hl.dsp.window.resize({ x = 960, y = 648, relative = false, window = w }))
            hl.dispatch(hl.dsp.window.center({ window = w }))
          end
        end
      end)
    '';
  };
}
