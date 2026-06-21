{host, ...}: let
  vars = import ../../../hosts/${host}/variables.nix;
  inherit (vars) barChoice browser terminal;
  qylockTheme = vars.qylockTheme or "";
in {
  wayland.windowManager.hyprland.extraConfig = ''
    # 1. WINDOW RESIZING
    binde = $modifier ALT, left, resizeactive, -10% 0 #"Resize Window to the Left"
    binde = $modifier ALT, right, resizeactive, 10% 0 #"Resize Window to the right"
    binde = $modifier ALT, up, resizeactive, 0 -10% #"Resize Window Upward"
    binde = $modifier ALT, down, resizeactive, 0 10% #"Resize Window Downward"

    # 2. MOUSE
    bindm = $modifier, mouse:272, movewindow #"Move Window"
    bindm = $modifier, mouse:273, resizewindow #"Resize Window"

    ${
      if barChoice == "noctalia"
      then
        ''
          # 3. NOCTALIA
          bind = $modifier, A, exec, noctalia msg panel-toggle launcher #"Noctalia Launcher"
          bind = $modifier, V, exec, noctalia msg panel-toggle clipboard #"Noctalia Clipboard"
          bind = $modifier, C, exec, noctalia msg panel-toggle control-center #"Noctalia Control Center"
          bind = $modifier CTRL, C, exec, noctalia msg settings-toggle #"Noctalia Settings"
          bind = $modifier SHIFT, W, exec, noctalia msg panel-toggle wallpaper #"Noctalia Wallpaper"
          bind = $modifier, N, exec, noctalia msg panel-toggle control-center "notifications" #"Notifications"
          bind = $modifier, E, exec, noctalia msg panel-toggle launcher "/emo" #"Emoji Picker"
          bind = $modifier CTRL, S, exec, noctalia msg screenshot-fullscreen #"Screenshot Fullscreen"
          bind = $modifier SHIFT, S, exec, noctalia msg screenshot-region #"Screenshot Region"
          # bind = $modifier CTRL, S, exec, hyprshot -m output -o "$HOME/Pictures/Screenshots" #"Screenshot Entire Screen"
          # bind = $modifier SHIFT, S, exec, hyprshot -m region -o "$HOME/Pictures/Screenshots" #"Screenshot Region"
          bind = $modifier ALT, S, exec, hyprshot -m window -o "$HOME/Pictures/Screenshots" #"Screenshot Window"
          # bind = $modifier SHIFT, E, exec, noctalia msg panel-toggle plugin:kaomoji #"Kaomoji Picker"
          # bind = $modifier, K, exec, noctalia msg panel-toggle plugin:keybind-cheatsheet #"Keybind Cheatsheet"
          bind = $modifier, R, exec, noctalia msg scripted-widget screen_recorder focused toggle #"Toggle Screen Recorder"
          bind = $modifier SHIFT, R, exec, killall -q noctalia; sleep 1; noctalia; #"Restart Noctalia shell"
          bind = $modifier ALT, R, exec, hyprctl reload #"Reload Hyprland"
          bind = CTRL+ALT, Delete, exec, noctalia msg panel-toggle session #"Noctalia Power Menu"
          bind = $modifier, Delete, exit #"Hyprland Logout/Exit"
        ''
        + (
          if qylockTheme == ""
          then ''
            bind = $modifier, L, exec, noctalia msg session lock #"Noctalia Lock Screen"
          ''
          else ''
            bind = $modifier, L, exec, qylock-lock #"Lock with qylock"
          ''
        )
      else ''
        # 3. ROFI
        bind = $modifier, D, exec, rofi-launcher #"Rofi Launcher"
        bind = $modifier SHIFT, Return, exec, rofi-launcher #"Rofi Launcher"
        bind = $modifier, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy #"Clipboard History"
      ''
    }

    # 4. APPLICATIONS
    bind = $modifier, Return, exec, ${terminal} #"Terminal"
    bind = $modifier, D, exec, app2unit -- discord #"Discord"
    bind = $modifier, S, exec, app2unit -- spotify #"Spotify"
    bind = $modifier, Z, exec, app2unit -- zeditor #"Zed"
    bind = $modifier, W, exec, app2unit -- ${browser} #"Web Browser"
    bind = $modifier ALT, W, exec, web-search #"Web Search"
    unbind = $modifier, O
    bind = $modifier, O, exec, obs #"OBS Studio"
    bind = $modifier ALT, C, exec, hyprpicker -a #"Color Picker"
    bind = $modifier, G, exec, gimp #"GIMP"
    bind = $modifier SHIFT, T, exec, sh -lc 'DropTerminal' #"Dropdown Terminal"
    bind = $modifier, T, exec, thunar #"Thunar"
    bind = $modifier, Y, exec, kitty -e yazi #"Yazi"
    bind = $modifier ALT, M, exec, pavucontrol #"Audio Control"

    # 5. WINDOW MANAGEMENT
    bind = $modifier, Q, killactive, #"Kill Active Window"
    bind = $modifier, P, pseudo, #"Pseudo Tile"
    bind = $modifier SHIFT, I, layoutmsg, togglesplit #"Toggle Split"
    bind = $modifier, F, fullscreen, #"Maximize"
    bind = $modifier SHIFT, F, togglefloating, #"Toggle Floating"
    bind = $modifier SHIFT, F, resizeactive, exact 1600 900
    bind = $modifier SHIFT, F, centerwindow
    bind = $modifier ALT, F, exec, hyprland-float-all #"Float All Windows"

    # 6. LAYOUTS
    bind = $modifier ALT, L, exec, hyprland-change-layout toggle #"Toggle Layouts"
    bind = $modifier ALT, 1, exec, hyprland-change-layout dwindle #"Layout Dwindle"
    bind = $modifier ALT, 2, exec, hyprland-change-layout master #"Layout Master"
    bind = $modifier ALT, 3, exec, hyprland-change-layout scrolling #"Layout Scrolling"
    bind = $modifier ALT, 4, exec, hyprland-change-layout monocle #"Layout Monocle"

    # 7. WINDOW MOVEMENT
    bind = $modifier SHIFT, left, movewindow, l #"Move Left"
    bind = $modifier SHIFT, right, movewindow, r #"Move Right"
    bind = $modifier SHIFT, up, movewindow, u #"Move Up"
    bind = $modifier SHIFT, down, movewindow, d #"Move Down"

    # 8. FOCUS MOVEMENT
    bind = $modifier, left, movefocus, l #"Focus Left"
    bind = $modifier, right, movefocus, r #"Focus Right"
    bind = $modifier, up, movefocus, u #"Focus Up"
    bind = $modifier, down, movefocus, d #"Focus Down"

    # 9. WORKSPACE SWITCHING
    bind = $modifier, 1, workspace, 1 #"Workspace 1"
    bind = $modifier, 2, workspace, 2 #"Workspace 2"
    bind = $modifier, 3, workspace, 3 #"Workspace 3"
    bind = $modifier, 4, workspace, 4 #"Workspace 4"
    bind = $modifier, 5, workspace, 5 #"Workspace 5"
    bind = $modifier, 6, workspace, 6 #"Workspace 6"
    bind = $modifier, 7, workspace, 7 #"Workspace 7"
    bind = $modifier, 8, workspace, 8 #"Workspace 8"
    bind = $modifier, 9, workspace, 9 #"Workspace 9"
    bind = $modifier, 0, workspace, 10 #"Workspace 10"

    # 10. MOVE WINDOW TO WORKSPACE
    binde = $modifier CTRL SHIFT, left, movetoworkspace, -1 #"Move to Left Workspace"
    binde = $modifier CTRL SHIFT, right, movetoworkspace, +1 #"Move to Right Workspace"
    bind = $modifier, SPACE, togglespecialworkspace #"Toggle Special Workspace"
    bind = $modifier SHIFT, SPACE, movetoworkspace, special #"Move to Special"
    bind = $modifier CTRL SHIFT, up, movetoworkspace, special #"Move to Special"
    bind = $modifier CTRL SHIFT, down, movetoworkspace, e+0 #"Move out of Special"
    bind = $modifier SHIFT, 1, movetoworkspace, 1 #"Move to Workspace 1"
    bind = $modifier SHIFT, 2, movetoworkspace, 2 #"Move to Workspace 2"
    bind = $modifier SHIFT, 3, movetoworkspace, 3 #"Move to Workspace 3"
    bind = $modifier SHIFT, 4, movetoworkspace, 4 #"Move to Workspace 4"
    bind = $modifier SHIFT, 5, movetoworkspace, 5 #"Move to Workspace 5"
    bind = $modifier SHIFT, 6, movetoworkspace, 6 #"Move to Workspace 6"
    bind = $modifier SHIFT, 7, movetoworkspace, 7 #"Move to Workspace 7"
    bind = $modifier SHIFT, 8, movetoworkspace, 8 #"Move to Workspace 8"
    bind = $modifier SHIFT, 9, movetoworkspace, 9 #"Move to Workspace 9"
    bind = $modifier SHIFT, 0, movetoworkspace, 10 #"Move to Workspace 10"

    # 11. WORKSPACE NAVIGATION
    bind = $modifier CONTROL, right, workspace, e+1 #"Next Workspace"
    bind = $modifier CONTROL, left, workspace, e-1 #"Previous Workspace"
    bind = $modifier, mouse_down, workspace, e+1 #"Next Workspace Mouse"
    bind = $modifier, mouse_up, workspace, e-1 #"Previous Workspace Mouse"

    # 12. WINDOW CYCLING
    bind = ALT, Tab, cyclenext #"Cycle Next Window"
    bind = ALT, Tab, bringactivetotop #"Bring Active To Top"

    # 13. MEDIA & HARDWARE CONTROLS
    bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ #"Volume Up"
    bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- #"Volume Down"
    bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle #"Mute Toggle"
    bind = , XF86AudioPlay, exec, playerctl play-pause #"Play Pause"
    bind = , XF86AudioPause, exec, playerctl play-pause #"Play Pause"
    bind = , XF86AudioNext, exec, playerctl next #"Next Track"
    bind = , XF86AudioPrev, exec, playerctl previous #"Previous Track"
    bind = , XF86MonBrightnessDown, exec, noctalia msg brightness-down #"Brightness Down"
    bind = , XF86MonBrightnessUp, exec, noctalia msg brightness-up #"Brightness Up"
  '';
}
