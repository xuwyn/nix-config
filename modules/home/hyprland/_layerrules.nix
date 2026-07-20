{
  wayland.windowManager.hyprland.settings.layer_rule = [
    # Noctalia Blur
    {
      name = "noctalia";
      match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
      };
      no_anim = true;
      ignore_alpha = 0.5;
      blur = true;
      blur_popups = true;
    }

    # DankMaterialShell Animation
    {
      match = {
        namespace = "dms:control-center";
      };
      # animation = "slide right";
      no_anim = true;
    }

    {
      match = {
        namespace = "dms:dash";
      };
      # animation = "slide right";
      no_anim = true;
    }

    # DankMaterialShell Blur
    {
      match = {
        namespace = "^dms:bar$";
      };
      xray = true;
    }

    {
      match = {
        namespace = "dms:(color-picker|clipboard|spotlight|settings)";
      };
      blur = true;
      blur_popups = true;
      ignore_alpha = 0;
    }

    {
      match = {
        namespace = "dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)";
      };
      blur = true;
      ignore_alpha = 0;
    }

    {
      match = {
        namespace = "dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)";
      };
      blur = true;
      ignore_alpha = 0;
    }
  ];
}
