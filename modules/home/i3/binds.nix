{
  pkgs,
  lib,
  host,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) terminal browser;
in {
  xsession.windowManager.i3 = {
    config = rec {
      modifier = "Mod4";

      keybindings = lib.mkOptionDefault {
        # Audio
        "XF86AudioMute" = "exec ${pkgs.i3-volume}/bin/i3-volume mute";
        "XF86AudioLowerVolume" = "exec ${pkgs.i3-volume}/bin/i3-volume down";
        "XF86AudioRaiseVolume" = "exec ${pkgs.i3-volume}/bin/i3-volume up";

        # Media Player
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

        # Brightness (via ddcutil)
        "XF86MonBrightnessDown" = "exec ${pkgs.ddcutil}/bin/ddcutil setvcp 10 - 10";
        "XF86MonBrightnessUp" = "exec ${pkgs.ddcutil}/bin/ddcutil setvcp 10 + 10";

        # Apps
        "${modifier}+Return" = "exec app2unit -- ${terminal}";
        "${modifier}+w" = "exec app2unit -- ${browser}";
        "${modifier}+z" = "exec app2unit -- zeditor";
        "${modifier}+s" = "exec app2unit -- spotify";
        "${modifier}+d" = "exec app2unit -- discord";
        "${modifier}+t" = "exec app2unit -- thunar";

        # Reload polybar
        "${modifier}+Mod1+r" = "exec --no-startup-id polybar-launcher";

        # Rofi
        "${modifier}+a" = "exec rofi-launcher";
        "${modifier}+Mod1+w" = "exec web-search";
        "${modifier}+Shift+a" = "exec ${pkgs.rofi}/bin/rofi -show window";

        # Clipboard
        "${modifier}+Shift+v" = "exec ${pkgs.rofi}/bin/rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'";
        "${modifier}+Mod1+v" = "exec pkill greenclip && sleep .5 && greenclip clear && greenclip daemon &";

        # Screenshot
        "${modifier}+Control+s" = "exec --no-startup-id mkdir -p ~/Pictures/Screenshots && ${pkgs.maim}/bin/maim | tee ~/Pictures/Screenshots/$(date +%F-%H%M%S).png | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
        "${modifier}+Shift+s" = "exec --no-startup-id mkdir -p ~/Pictures/Screenshots && ${pkgs.maim}/bin/maim -s | tee ~/Pictures/Screenshots/$(date +%F-%H%M%S).png | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";

        # Session Menu
        "Control+Mod1+Delete" = "exec powermenu";
        "${modifier}+l" = "exec i3-lock";

        # Kill Active Window
        "${modifier}+q" = "kill";

        # Move to Workspace 1-10
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        # Move Window to Workspace 1-10
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Move Active Window to Next/Prev Workspace
        "${modifier}+Control+Shift+Left" = "move container to workspace prev_on_output, workspace prev_on_output";
        "${modifier}+Control+Shift+Right" = "move container to workspace next_on_output, workspace next_on_output";

        # Workspaces Cycle (Next / Prev)
        "${modifier}+Control+Left" = "workspace prev";
        "${modifier}+Control+Right" = "workspace next";

        # Specific Layouts
        "${modifier}+Mod1+1" = "layout splith";
        "${modifier}+Mod1+2" = "layout splitv";
        "${modifier}+Mod1+3" = "layout stacking";
        "${modifier}+Mod1+4" = "layout tabbed";
        "${modifier}+v" = "split v";
        "${modifier}+h" = "split h";

        # Cycle Layouts
        "${modifier}+Mod1+l" = "layout toggle all";

        # Fullscreen toggle
        "${modifier}+f" = "fullscreen toggle";

        # Floating
        "${modifier}+Shift+f" = "floating toggle";
        "${modifier}+Mod1+f" = "floating enable";
      };
    };
  };
}
