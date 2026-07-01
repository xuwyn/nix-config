{
  flake.modules.homeManager.i3 = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.i3.polybar;
    isStylixEnabled = config.homeManager.theme.stylix.enable or false;
    colors =
      if isStylixEnabled
      then {
        background = config.lib.stylix.colors.base00;
        backgroundAlt = config.lib.stylix.colors.base01;
        base02 = config.lib.stylix.colors.base02;
        base03 = config.lib.stylix.colors.base03;
        foreground = config.lib.stylix.colors.base05;
        base07 = config.lib.stylix.colors.base07;
        base08 = config.lib.stylix.colors.base08;
        primary = config.lib.stylix.colors.base0D;
      }
      else {
        background = "1e1e2e"; # Base
        backgroundAlt = "181825"; # Mantle
        base02 = "313244"; # Surface0
        base03 = "45475a"; # Surface1
        foreground = "cdd6f4"; # Text
        base07 = "b4befe"; # Lavender (used as accent here)
        base08 = "f38ba8"; # Red (used for urgent)
        primary = "89b4fa"; # Blue
      };
  in {
    options.homeManager.i3.polybar = {
      enable = lib.mkEnableOption "Enable polybar";
    };
    config = lib.mkIf cfg.enable {
      services.polybar = {
        enable = true;
        # config = ./config.ini;
        package = pkgs.polybar.override {
          i3Support = true;
          alsaSupport = true;
          pulseSupport = true;
        };
        script = "polybar &";

        config = {
          "bar/i3-bar" = {
            monitor = "\${env:MONITOR}";
            height = "3.3%";
            modules-left = "i3 memory cpu temperature";
            modules-center = "media";
            modules-right = "volume wireless-network time date";

            module-margin = 2;
            border-top-size = 12;
            border-left-size = 15;
            border-right-size = 15;
            padding = 3;
            radius = 8;

            font-0 = "Maple Mono NF:size=10:antialias=true;2";
            font-1 = "JetBrainsMono Nerd Font:size=12;2";
            font-2 = "Noto Sans CJK JP:size=10;2";

            background = "#90${colors.background}";
            foreground = "#${colors.foreground}";
            background-alt = "#${colors.backgroundAlt}";
            primary = "#${colors.primary}";
          };
        };

        extraConfig = ''
          [module/i3]
          type = internal/i3

          ; Only show workspaces defined on the same output as the bar
          pin-workspaces = true

          ; Show workspaces that don't have windows open but are assigned to this screen
          show-urgent = true
          strip-wsnumbers = false
          index-sort = true

          ; Available tags:
          ; <label-state> (default) - gets replaced with labels for open/focused/empty workspaces
          format = <label-state>

          ; Focused workspace on active monitor
          label-focused = %index%
          label-focused-background = #313244
          label-focused-foreground = #${colors.foreground}
          label-focused-underline = #${colors.primary}
          label-focused-padding = 2

          ; Unfocused workspace on any monitor (has windows open but not viewed right now)
          label-unfocused = %index%
          label-unfocused-padding = 2
          label-unfocused-foreground = #${colors.base03}

          ; Visible workspace on an inactive monitor (for multi-monitor setups)
          label-visible = %index%
          label-visible-background = #${colors.backgroundAlt}
          label-visible-padding = 2

          ; Urgent workspace (e.g., a window demands attention)
          label-urgent = %index%
          label-urgent-background = #${colors.base07}
          label-urgent-padding = 2

          [module/date]
          type = internal/date
          interval = 1.0
          format = <label>
          date = " %a %b %d %Y"
          label = %date%

          [module/time]
          type = internal/date
          interval = 1.0
          format = <label>
          time = " %I:%M %P"
          label = %time%

          [module/volume]
          type = internal/pulseaudio
          use-ui-max = true
          interval = 5
          reverse-scroll = false
          label-volume = "%percentage%%"
          ramp-volume-0 = 󰕿
          ramp-volume-1 = 󰖀
          ramp-volume-2 = 󰕾
          format-volume = <ramp-volume> <label-volume>

          format-muted = 󰝟 0%
          format-muted-foreground = #${colors.base07}

          click-right = pavucontrol

          [module/temperature]
          type = internal/temperature
          interval = 0.5
          base-temperature = 20
          warn-temperature = 70
          hwmon-path = "''${env:CPU_HWMON_PATH}"
          label-warn-foreground = #${colors.base07}
          format = <ramp> <label>
          format-warn = <ramp> <label-warn>
          ramp-0 = 
          ramp-1 = 
          ramp-2 = 
          ; ramp-foreground = #${colors.base07}

          [module/wireless-network]
          type = internal/network
          ; interface = wlan0
          interface-type = wireless
          interval = 1.0 # sleep in seconds between update

          format-connected = <ramp-signal> <label-connected>
          format-connected-padding = 1
          format-disconnected = <label-disconnected>
          format-disconnected-padding = 1

          ; Available tokens:
          ;   %percentage% (default)
          ;   %essid%
          ;   %local_ip%
          ;   %upspeed%
          ;   %downspeed%
          label-connected = %{A1:nm-connection-editor:}%essid%%{A}
          label-disconnected = 󰤮 Disconnected

          ramp-signal-0 = 󰤯
          ramp-signal-1 = 󰤟
          ramp-signal-2 = 󰤢
          ramp-signal-3 = 󰤥
          ramp-signal-4 = 󰤨

          [module/memory]
          type = internal/memory
          interval = 0.5
          warn-percentage = 90

          format = <label>
          format-warn = <label-warn>

          label =  %gb_used% / %gb_total%
          label-warn =  %{F#${colors.base07}}%gb_used%%{F-} / %gb_total%

          [module/cpu]
          type = internal/cpu
          interval = 0.5
          warn-percentage = 80

          ; Available tags:
          ;   <label-warn>
          ;   <bar-load>
          ;   <ramp-load>
          ;   <ramp-coreload>
          format = 󰓅 <label>
          format-warn = 󰓅 <label-warn>

          label = %percentage%%
          label-warn= %{F#${colors.base07}}%percentage%%%{F-}

          ramp-load-0 = ▁
          ramp-load-1 = ▂
          ramp-load-2 = ▃
          ramp-load-3 = ▄
          ramp-load-4 = ▅
          ramp-load-5 = ▆
          ramp-load-6 = ▇
          ramp-load-7 = █

          ramp-coreload-spacing = 1
          ramp-coreload-0 = ▁
          ramp-coreload-1 = ▂
          ramp-coreload-2 = ▃
          ramp-coreload-3 = ▄
          ramp-coreload-4 = ▅
          ramp-coreload-5 = ▆
          ramp-coreload-6 = ▇
          ramp-coreload-7 = █

          [module/media]
          type = custom/script
          interval = 2
          format-prefix = " "
          format = <label>
          exec = ${pkgs.zsh}/bin/zsh -c "media-status"

          # Optional: Click actions
          click-left = ${pkgs.playerctl}/bin/playerctl play-pause
          click-right = ${pkgs.playerctl}/bin/playerctl next
        '';
      };
    };
  };
}
