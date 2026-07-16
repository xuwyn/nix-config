{
  modules.homeManager.aerospace = {
    pkgs,
    username,
    ...
  }: {
    # WM for MacOS
    programs.aerospace = {
      enable = true;
      package = pkgs.aerospace;

      launchd = {
        enable = true;
        keepAlive = true;
      };

      settings = {
        # See https://nikitabobko.github.io/AeroSpace/guide for all keys

        key-mapping.preset = "qwerty";

        gaps = {
          inner.horizontal = 8;
          inner.vertical = 8;
          outer.left = 8;
          outer.bottom = 8;
          outer.top = 8;
          outer.right = 8;
        };

        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        on-window-detected = [
          {
            # move all instances of finder to workspace 9
            "if".app-id = "com.apple.finder";
            run = "move-node-to-workspace 9";
          }
        ];

        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";

          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";

          alt-ctrl-left = "workspace prev";
          alt-ctrl-right = "workspace next";

          alt-f = "fullscreen";
          alt-shift-space = "layout floating tiling";

          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";
          alt-0 = "balance-sizes"; # reset all sizes to equal

          alt-e = "exec-and-forget open ~";
        };
      };
    };
  };
}
