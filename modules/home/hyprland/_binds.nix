{config, ...}: let
  inherit (config.homeManager.hyprland) browser terminal barChoice qylock;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    -- 1. WINDOW RESIZING
    hl.bind("SUPER + ALT + left", function() local w = hl.get_active_window(); if not w then return end; hl.dispatch(hl.dsp.window.resize({ x = math.floor(w.size.x * -10 / 100), y = 0, relative = true })) end, { repeating = true })
    hl.bind("SUPER + ALT + right", function() local w = hl.get_active_window(); if not w then return end; hl.dispatch(hl.dsp.window.resize({ x = math.floor(w.size.x * 10 / 100), y = 0, relative = true })) end, { repeating = true })
    hl.bind("SUPER + ALT + up", function() local w = hl.get_active_window(); if not w then return end; hl.dispatch(hl.dsp.window.resize({ x = 0, y = math.floor(w.size.y * -10 / 100), relative = true })) end, { repeating = true })
    hl.bind("SUPER + ALT + down", function() local w = hl.get_active_window(); if not w then return end; hl.dispatch(hl.dsp.window.resize({ x = 0, y = math.floor(w.size.y * 10 / 100), relative = true })) end, { repeating = true })

    -- 2. MOUSE
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

    ${
      if barChoice == "noctalia"
      then
        ''
          -- 3. NOCTALIA
          hl.bind("SUPER + A", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
          hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
          hl.bind("SUPER + C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
          hl.bind("SUPER + CTRL + C", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
          hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
          hl.bind("SUPER + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center \"notifications\""))
          hl.bind("SUPER + E", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher \"/emo\""))
          hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))
          hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
          hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd("hyprshot -m window -o \"$HOME/Pictures/Screenshots\""))
          hl.bind("SUPER + R", hl.dsp.exec_cmd("noctalia msg plugin noctalia/screen_recorder:service all toggle"))
          hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("killall -q noctalia; sleep 1; noctalia;"))
          hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("hyprctl reload"))
          hl.bind("CTRL+ALT + Delete", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
          hl.bind("SUPER + Delete", hl.dsp.exit())

          -- hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("hyprshot -m output -o \"$HOME/Pictures/Screenshots\""))
          -- hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o \"$HOME/Pictures/Screenshots\""))
          -- hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("noctalia msg panel-toggle plugin:kaomoji"))
          -- hl.bind("SUPER + K", hl.dsp.exec_cmd("noctalia msg panel-toggle plugin:keybind-cheatsheet"))
        ''
        + (
          if !qylock.enable
          then ''
            hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"))
          ''
          else ''
            hl.bind("SUPER + L", hl.dsp.exec_cmd("qylock-lock"))
          ''
        )
      else ''
        -- 3. ROFI
        hl.bind("SUPER + A", hl.dsp.exec_cmd("rofi-launcher"))
        hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("rofi -show window"))
        hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
      ''
    }

    -- 4. APPLICATIONS
    hl.bind("SUPER + Return", hl.dsp.exec_cmd("${terminal}"))
    hl.bind("SUPER + D", hl.dsp.exec_cmd("app2unit -- discord"))
    hl.bind("SUPER + S", hl.dsp.exec_cmd("app2unit -- spotify"))
    hl.bind("SUPER + Z", hl.dsp.exec_cmd("app2unit -- zeditor"))
    hl.bind("SUPER + W", hl.dsp.exec_cmd("app2unit -- ${browser}"))
    hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("web-search"))
    -- TODO: manual review — 'unbind = $modifier, O'. In Lua, capture the result of hl.bind(...) and call :remove(). See hl.meta.lua.
    hl.bind("SUPER + O", hl.dsp.exec_cmd("obs"))
    hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("hyprpicker -a"))
    hl.bind("SUPER + G", hl.dsp.exec_cmd("gimp"))
    hl.bind("SUPER + T", hl.dsp.exec_cmd("thunar"))
    hl.bind("SUPER + Y", hl.dsp.exec_cmd("kitty -e yazi"))
    hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("pavucontrol"))

    -- 5. WINDOW MANAGEMENT
    hl.bind("SUPER + Q", hl.dsp.window.close())
    hl.bind("SUPER + P", hl.dsp.window.pseudo())
    hl.bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"))
    hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

    -- Float Toggle
    hl.bind("SUPER + SHIFT + F", function()
      local window = hl.get_active_window()
      if window ~= nil then
        if window.floating then
          hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
          local w = hl.get_active_workspace()
          if not w then return end
          hl.workspace_rule({ workspace = tostring(w.id), layout = "dwindle" })
        else
          hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
          hl.dispatch(hl.dsp.window.resize({ x = 1600, y = 900 }))
          hl.dispatch(hl.dsp.window.center())
        end
      end
    end)

    -- Float all windows toggle
    hl.bind("SUPER + ALT + F", function ()
      local workspace = hl.get_active_workspace()
      if workspace == nil then
        return
      end
      local windows = hl.get_workspace_windows(workspace)
      for _, window in ipairs(windows) do
        hl.dispatch(hl.dsp.window.float({ window = window, action = "toggle" }))
        hl.dispatch(hl.dsp.window.center())
      end
    end)

    -- 6. LAYOUTS
    -- See: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Uncommon-tips-and-tricks/#cycle-layout-for-current-workspace
    hl.bind("SUPER + TAB", function ()
        local layouts     = { "scrolling", "dwindle", "master", "monocle" }
        local workspace   = hl.get_active_workspace()
      if hl.get_active_special_workspace() then
        workspace = hl.get_active_special_workspace()
      end
        local next_layout = "dwindle"
        if not workspace then
            return
        end
        for i = 1, #layouts do
            if layouts[i] == workspace.tiled_layout then
                local next_layout_idx = (i % #layouts) + 1
                next_layout = layouts[next_layout_idx]
                break
            end
        end
      if workspace.special then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
      else
        hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
      end
    end)

    hl.bind("SUPER + ALT + 1", function()
      local w = hl.get_active_workspace()
      if not w then return end
      hl.workspace_rule({ workspace = tostring(w.id), layout = "scrolling" })
    end)

    hl.bind("SUPER + ALT + 2", function()
      local w = hl.get_active_workspace()
      if not w then return end
      hl.workspace_rule({ workspace = tostring(w.id), layout = "dwindle" })
    end)

    hl.bind("SUPER + ALT + 3", function()
      local w = hl.get_active_workspace()
      if not w then return end
      hl.workspace_rule({ workspace = tostring(w.id), layout = "master" })
    end)

    hl.bind("SUPER + ALT + 4", function()
      local w = hl.get_active_workspace()
      if not w then return end
      hl.workspace_rule({ workspace = tostring(w.id), layout = "monocle" })
    end)

    -- 7. WINDOW MOVEMENT
    hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
    hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
    hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
    hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

    -- 8. FOCUS MOVEMENT
    hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
    hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
    hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
    hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

    -- 9. WORKSPACE SWITCHING
    hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
    hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
    hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
    hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
    hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
    hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
    hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
    hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
    hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
    hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

    -- 10. MOVE WINDOW TO WORKSPACE
    local function move_to_special_and_resize()
      hl.dispatch(hl.dsp.window.move({ workspace = "special" }))
      hl.dispatch(hl.dsp.window.float({ action = "set" }))
      hl.dispatch(hl.dsp.window.resize({ x = 1800, y = 1000, relative = false }))
    end
    local function move_out_from_special()
      hl.dispatch(hl.dsp.window.move({ workspace = "e+0" }))
      local ws = hl.get_active_workspace()
      if not ws then return end
      local w = hl.get_active_window()
      if w ~= nil and w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
      end
      hl.workspace_rule({ workspace = tostring(w.id), layout = "dwindle" })
    end
    hl.bind("SUPER + SPACE", hl.dsp.workspace.toggle_special(""))
    hl.bind("SUPER + SHIFT + SPACE", move_to_special_and_resize)
    hl.bind("SUPER + CTRL + SHIFT + up", move_to_special_and_resize)
    hl.bind("SUPER + CTRL + SHIFT + down", move_out_from_special)

    hl.bind("SUPER + CTRL + SHIFT + left", hl.dsp.window.move({ workspace = -1 }), { repeating = true })
    hl.bind("SUPER + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
    hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
    hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
    hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
    hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
    hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
    hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
    hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
    hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
    hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
    hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

    -- 11. WORKSPACE NAVIGATION
    hl.bind("SUPER + CONTROL + right", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + CONTROL + left", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

    -- 12. WINDOW CYCLING
    hl.bind("ALT + TAB", function()
      hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
      hl.dispatch(hl.dsp.window.bring_to_top())
    end)

    -- 13. MEDIA & HARDWARE CONTROLS
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"))
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up"))
  '';
}
