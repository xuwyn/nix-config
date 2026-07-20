{
  wayland.windowManager.hyprland.settings = {
    curve = {
      _args = [
        "Bezier"
        {
          type = "bezier";
          points = [
            [0.05 0.9]
            [0.1 1.05]
          ];
        }
      ];
    };
    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 7;
        bezier = "Bezier";
      }

      {
        leaf = "windowsOut";
        enabled = true;
        speed = 7;
        bezier = "default";
        style = "popin 80%";
      }

      {
        leaf = "border";
        enabled = true;
        speed = 10;
        bezier = "default";
      }

      {
        leaf = "borderangle";
        enabled = true;
        speed = 8;
        bezier = "default";
      }

      {
        leaf = "fade";
        enabled = true;
        speed = 7;
        bezier = "default";
      }

      {
        leaf = "workspaces";
        enabled = true;
        speed = 6;
        bezier = "default";
      }
    ];
  };
}
