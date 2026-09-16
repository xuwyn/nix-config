{
  wayland.windowManager.hyprland.settings.window_rule = [
    {
      name = "Firefox";
      match = {
        class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";
      };
      opacity = "1.0 0.9";
      no_blur = false;
    }
    {
      name = "Picture-in-Picture";
      match = {
        title = "^(Picture-in-Picture)$";
      };
      float = true;
      move = ["72%" "7%"];
      opacity = "0.95 0.75";
      pin = false;
      keep_aspect_ratio = true;
    }
    {
      name = "Zed";
      match = {
        class = "^(zed|dev\\.zed\\.Zed|Zed)$";
      };
      opacity = "0.90 0.80";
      no_blur = false;
    }
    {
      name = "Thunar";
      match = {
        class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$";
      };
      opacity = "0.95 0.85";
      no_blur = false;
      float = true;
      center = true;
    }
    {
      name = "Waydroid";
      match = {
        class = "^(Waydroid)$";
      };
      float = true;
    }
    {
      name = "WaydroidHelper";
      match = {
        class = "^(com\\.jaoushingan\\.WaydroidHelper)$";
      };
      float = true;
    }
    {
      name = "Arknights";
      match = {
        class = "^(waydroid\\.com\\.YoStarEN\\.Arknights)$";
      };
      float = true;
    }
    {
      name = "Terminals";
      match = {
        class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty)$";
      };
      opacity = "0.93 0.85";
      no_blur = false;
    }
    {
      name = "Discord";
      match = {
        class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$";
      };
      opacity = "0.94 0.86";
    }
    {
      name = "gamescope";
      match = {
        class = "^(gamescope)$";
      };
      no_blur = true;
      fullscreen = true;
    }
    {
      name = "steam-app";
      match = {
        class = "^steam_app_\\d+$";
      };
      no_blur = true;
      fullscreen = true;
    }
    {
      name = "Steam";
      match = {
        class = "^([Ss]team)$";
      };
      float = true;
    }
    {
      name = "FileRoller";
      match = {
        class = "^(file-roller|org.gnome.FileRoller)$";
      };
      float = true;
      opacity = "0.95 0.85";
      size = ["70%" "70%"];
      no_blur = false;
    }
    {
      name = "NetworkManger";
      match = {
        class = "^(nm-applet|nm-connection-editor|blueman-manager)$";
      };
      float = true;
      opacity = "0.95 0.85";
      size = ["70%" "70%"];
      no_blur = false;
    }
    {
      name = "Authentication-Required";
      match = {
        title = "^(Authentication Required)$";
      };
      center = true;
      float = true;
    }
    {
      name = "Add-Folder";
      match = {
        initial_title = "(Add Folder to Workspace)";
      };
      float = true;
      size = ["70%" "60%"];
    }
    {
      name = "Open-File";
      match = {
        initial_title = "(Open Files)";
      };
      float = true;
      size = ["70%" "60%"];
    }
    {
      name = "Wants-to-Save";
      match = {
        initial_title = "(wants to save)";
      };
      float = true;
    }
  ];
}
