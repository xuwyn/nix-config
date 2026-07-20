{
  wayland.windowManager.hyprland.settings.window_rule = [
    {
      name = "Settings-Tag";
      match = {
        tag = "settings*";
      };
      float = true;
      opacity = "0.95 0.85";
      size = "70% = 70%";
      no_blur = false;
    }

    {
      name = "Browsers-Tag";
      match = {
        tag = "browser*";
      };
      opacity = "1.0 0.9";
      no_blur = false;
    }

    {
      name = "Projects-Tag";
      match = {
        tag = "projects*";
      };
      opacity = "0.98 0.93";
      no_blur = false;
    }

    {
      name = "Instant-Messaging-Tag";
      match = {
        tag = "im*";
      };
      opacity = "0.94 0.86";
    }

    {
      name = "File-Managers-Tag";
      match = {
        tag = "file-manager*";
      };
      opacity = "0.95 0.85";
      no_blur = false;
    }

    {
      name = "Terminals-Tag";
      match = {
        tag = "terminal*";
      };
      opacity = "0.90 0.80";
      no_blur = false;
    }

    {
      name = "Games-Tag";
      match = {
        tag = "games*";
      };
      no_blur = true;
      fullscreen = true;
    }

    {
      name = "Thunar";
      match = {
        class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$";
      };
      tag = "+file-manager";
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
      tag = "+terminal";
    }

    {
      name = "Firefox";
      match = {
        class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";
      };
      tag = "+browser";
    }

    {
      name = "Google-chrome";
      match = {
        class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$";
      };
      tag = "+browser";
    }

    {
      name = "zed";
      match = {
        class = "^(zed|dev\\.zed\\.Zed|Zed)$";
      };
      tag = "+projects";
    }

    {
      name = "Discord";
      match = {
        class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$";
      };
      tag = "+im";
    }

    {
      name = "teams-for-linux";
      match = {
        class = "^(teams-for-linux)$";
      };
      tag = "+im";
    }

    {
      name = "gamescope";
      match = {
        class = "^(gamescope)$";
      };
      tag = "+games";
    }

    {
      name = "steam-app";
      match = {
        class = "^(steam_app\\d+)$";
      };
      tag = "+games";
    }

    {
      name = "Steam";
      match = {
        class = "^([Ss]team)$";
      };
      tag = "+gamestore";
      float = true;
    }

    {
      name = "rofi";
      match = {
        class = "^([Rr]ofi)$";
      };
      tag = "+settings";
    }

    {
      name = "FileRoller";
      match = {
        class = "^(file-roller|org.gnome.FileRoller)$";
      };
      tag = "+settings";
    }

    {
      name = "NetworkManger";
      match = {
        class = "^(nm-applet|nm-connection-editor|blueman-manager)$";
      };
      tag = "+settings";
    }

    {
      name = "PlusAudio";
      match = {
        class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";
      };
      center = true;
      tag = "+settings";
    }

    {
      name = "xdg-desktop-portal-gtk";
      match = {
        class = "(xdg-desktop-portal-gtk)";
      };
      tag = "+settings";
    }

    {
      name = "blueman";
      match = {
        class = "(.blueman-manager-wrapped)";
      };
      tag = "+settings";
    }

    {
      name = "Picture-in-Picture";
      match = {
        title = "^(Picture-in-Picture)$";
      };
      float = true;
      move = "72% = 7%";
      opacity = "0.95 0.75";
      pin = false;
      keep_aspect_ratio = true;
    }

    {
      name = "ThunarFileMgr";
      match = {
        class = "([Tt]hunar)";
        title = "negative:(.*[Tt]hunar.*)";
      };
      center = true;
      float = true;
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
      name = "IdleInhibit-fullscreen-1";
      match = {
        class = "^(*)$";
      };
      idle_inhibit = "fullscreen";
    }

    {
      name = "IdleInhibit-fullscreen-2";
      match = {
        title = "^(*)$";
      };
      idle_inhibit = "fullscreen";
    }

    {
      name = "IdleInhibit-fullscreen-3";
      match = {
        fullscreen = 1;
      };
      idle_inhibit = "fullscreen";
    }

    {
      name = "mpv-or-clapper";
      match = {
        class = "^(mpv|com.github.rafostar.Clapper)$";
      };
      float = true;
    }

    {
      name = "Add-Folder";
      match = {
        initial_title = "(Add Folder to Workspace)";
      };
      float = true;
      size = "70% = 60%";
    }

    {
      name = "Open-File";
      match = {
        initial_title = "(Open Files)";
      };
      float = true;
      size = "70% = 60%";
    }

    {
      name = "Wants-to-Save";
      match = {
        initial_title = "(wants to save)";
      };
      float = true;
    }

    {
      name = "seahorse";
      match = {
        class = "^(seahorse)$";
      };
      opacity = "0.9 0.8";
    }
  ];
}
