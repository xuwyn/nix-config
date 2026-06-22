_: {
  wayland.windowManager.hyprland.extraConfig = ''

    hl.window_rule({
        name = "Resolve",
        match = {
            class = "^(\\bresolve\\b)$",
            xwayland = 1,
        },
        no_blur = true,
    })

    hl.window_rule({
        name = "Thunar",
        match = {
            class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$",
        },
        tag = "+file-manager",
        opacity = "0.85 0.75",
        no_blur = false,
    })

    hl.window_rule({
        name = "Terminals",
        match = {
            class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm|dropterminal)$",
        },
        tag = "+terminal",
    })

    hl.window_rule({
        name = "Firefox",
        match = {
            class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$",
        },
        tag = "+browser",
    })

    hl.window_rule({
        name = "Google-chrome",
        match = {
            class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$",
        },
        tag = "+browser",
    })

    hl.window_rule({
        name = "vscodium",
        match = {
            class = "^(codium|codium-url-handler|VSCodium)$",
        },
        tag = "+projects",
    })

    hl.window_rule({
        name = "vscode",
        match = {
            class = "^(VSCode|code-url-handler)$",
        },
        tag = "+projects",
    })

    hl.window_rule({
        name = "Discord",
        match = {
            class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
        },
        tag = "+im",
    })

    hl.window_rule({
        name = "Ferdium",
        match = {
            class = "^([Ff]erdium)$",
        },
        center = true,
        float = true,
        size = "60% = 70%",
        tag = "+im",
    })

    hl.window_rule({
        name = "Whatsapp",
        match = {
            class = "^([Ww]hatsapp-for-linux)$",
        },
        tag = "+im",
    })

    hl.window_rule({
        name = "Telegram-desktop",
        match = {
            class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$",
        },
        tag = "+im",
    })

    hl.window_rule({
        name = "teams-for-linux",
        match = {
            class = "^(teams-for-linux)$",
        },
        tag = "+im",
    })

    hl.window_rule({
        name = "gamescope",
        match = {
            class = "^(gamescope)$",
        },
        tag = "+games",
    })

    hl.window_rule({
        name = "steam-app",
        match = {
            class = "^(steam_app\\d+)$",
        },
        tag = "+games",
    })

    hl.window_rule({
        name = "Steam",
        match = {
            class = "^([Ss]team)$",
        },
        tag = "+gamestore",
    })

    hl.window_rule({
        name = "Lutris",
        match = {
            title = "^([Ll]utris)$",
        },
        tag = "+gamestore",
    })

    hl.window_rule({
        name = "heroicgameslauncher",
        match = {
            class = "^(com.heroicgameslauncher.hgl)$",
        },
        tag = "+gamestore",
    })

    hl.window_rule({
        name = "gnome-disks",
        match = {
            class = "^(gnome-disks|wihotspot(-gui)?)$",
        },
        tag = "+settings",
    })

    hl.window_rule({
        name = "rofi",
        match = {
            class = "^([Rr]ofi)$",
        },
        tag = "+settings",
        no_blur = false,
    })

    hl.window_rule({
        name = "FileRoller",
        match = {
            class = "^(file-roller|org.gnome.FileRoller)$",
        },
        tag = "+settings",
    })

    hl.window_rule({
        name = "NetworkManger",
        match = {
            class = "^(nm-applet|nm-connection-editor|blueman-manager)$",
        },
        tag = "+settings",
    })

    hl.window_rule({
        name = "PlusAudio",
        match = {
            class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
        },
        center = true,
        tag = "+settings",
        no_blur = false,
    })

    hl.window_rule({
        name = "xdg-desktop-portal-gtk",
        match = {
            class = "(xdg-desktop-portal-gtk)",
        },
        tag = "+settings",
    })

    hl.window_rule({
        name = "blueman",
        match = {
            class = "(.blueman-manager-wrapped)",
        },
        tag = "+settings",
    })

    hl.window_rule({
        name = "Picture-in-Picture",
        match = {
            title = "^(Picture-in-Picture)$",
        },
        float = true,
        move = "72% = 7%",
        opacity = "0.95 0.75",
        pin = false,
        keep_aspect_ratio = true,
    })

    hl.window_rule({
        name = "ThunarFileMgr",
        match = {
            class = "([Tt]hunar)",
            title = "negative:(.*[Tt]hunar.*)",
        },
        center = true,
        float = true,
    })

    hl.window_rule({
        name = "Authentication-Required",
        match = {
            title = "^(Authentication Required)$",
        },
        center = true,
        float = true,
    })

    hl.window_rule({
        name = "IdleInhibit-fullscreen-1",
        match = {
            class = "^(*)$",
        },
        idle_inhibit = "fullscreen",
    })

    hl.window_rule({
        name = "IdleInhibit-fullscreen-2",
        match = {
            title = "^(*)$",
        },
        idle_inhibit = "fullscreen",
    })

    hl.window_rule({
        name = "IdleInhibit-fullscreen-3",
        match = {
            fullscreen = 1,
        },
        idle_inhibit = "fullscreen",
    })

    hl.window_rule({
        name = "Settings-Tag",
        match = {
            tag = "settings*",
        },
        float = true,
        opacity = "0.8 0.7",
        size = "70% = 70%",
        no_blur = false,
    })

    hl.window_rule({
        name = "mpv-or-clapper",
        match = {
            class = "^(mpv|com.github.rafostar.Clapper)$",
        },
        float = true,
    })

    hl.window_rule({
        name = "codium-url-handler",
        match = {
            class = "(codium|codium-url-handler|VSCodium)",
            title = "negative:(.*codium.*|.*VSCodium.*)",
        },
        float = true,
    })

    hl.window_rule({
        name = "heroicgameslauncher-1",
        match = {
            class = "^(com.heroicgameslauncher.hgl)$",
            title = "negative:(Heroic Games Launcher)",
        },
        float = true,
    })

    hl.window_rule({
        name = "Steam",
        match = {
            class = "^([Ss]team)$",
            title = "negative:^([Ss]team)$",
        },
        float = true,
    })

    hl.window_rule({
        name = "Add-Folder",
        match = {
            initial_title = "(Add Folder to Workspace)",
        },
        float = true,
        size = "70% = 60%",
    })

    hl.window_rule({
        name = "Open-File",
        match = {
            initial_title = "(Open Files)",
        },
        float = true,
        size = "70% = 60%",
    })

    hl.window_rule({
        name = "Wants-to-Save",
        match = {
            initial_title = "(wants to save)",
        },
        float = true,
    })

    hl.window_rule({
        name = "Browsers",
        match = {
            tag = "browser*",
        },
        opacity = "1.0 0.9",
    })

    hl.window_rule({
        name = "Projects",
        match = {
            tag = "projects*",
        },
        opacity = "0.9 0.8",
    })

    hl.window_rule({
        name = "Instant-Messaging",
        match = {
            tag = "im*",
        },
        opacity = "0.94 0.86",
    })

    hl.window_rule({
        name = "File-Managers",
        match = {
            tag = "file-manager*",
        },
        opacity = "0.9 0.8",
    })

    hl.window_rule({
        name = "Terminals-opacity",
        match = {
            tag = "terminal*",
        },
        opacity = "0.9 0.8",
        no_blur = false,
    })

    hl.window_rule({
        name = "windowrule-77",
        match = {
            class = "^(gedit|org.gnome.TextEditor|mousepad)$",
        },
        opacity = "0.8 0.7",
    })

    hl.window_rule({
        name = "windowrule-78",
        match = {
            class = "^(seahorse)$",
        },
        opacity = "0.9 0.8",
    })

    hl.window_rule({
        name = "windowrule-79",
        match = {
            tag = "games*",
        },
        no_blur = true,
    })

    hl.window_rule({
        name = "windowrule-80",
        match = {
            tag = "games*",
        },
        fullscreen = true,
    })
  '';
}
