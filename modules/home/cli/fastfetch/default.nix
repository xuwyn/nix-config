{
  flake.modules.homeManager.cli = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.fastfetch;
  in {
    options.homeManager.cli.fastfetch = {
      enable = lib.mkEnableOption "Enable fastfetch";
      terminal = lib.mkOption {
        type = lib.types.enum ["kitty" "foot" "alacritty" "ghostty" "wezterm"];
        default = "kitty";
        description = "Choose terminal emulator";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.fastfetch = {
        enable = true;

        settings = {
          display = {
            # color = {
            #   keys = "35";
            #   output = "95";
            # };
            separator = " ➜  ";
          };

          logo = {
            source = ./frieren.png;
            type =
              if cfg.terminal == "wezterm"
              then "iterm"
              else "kitty-direct";
            height = 18;
            width = 25;
            padding = {
              top = 3;
              left = 0;
            };
          };

          modules = [
            "break"
            {
              type = "title";
              key = "OS   ";
              keyColor = "red";
              outputColor = "red";
            }
            {
              type = "os";
              key = " ├  ";
              keyColor = "red";
              outputColor = "red";
            }
            {
              type = "kernel";
              key = " ├  ";
              keyColor = "red";
              outputColor = "red";
            }
            {
              type = "packages";
              key = " ├ 󰏖 ";
              keyColor = "red";
              outputColor = "red";
            }
            {
              type = "terminal";
              key = " ├  ";
              keyColor = "red";
              outputColor = "red";
            }
            {
              type = "shell";
              key = " └  ";
              keyColor = "red";
              outputColor = "red";
            }
            "break"
            {
              type = "wm";
              key = "WM   ";
              keyColor = "green";
              outputColor = "green";
            }
            {
              type = "command";
              key = " ├ 󰏒 ";
              keyColor = "green";
              text = "noctalia --version";
              outputColor = "green";
            }
            {
              type = "command";
              key = " ├  ";
              keyColor = "green";
              text = "caelestia --version | awk '/caelestia-shell/ {printf \"%s v%s\\n\",$1,$2; exit}'";
              outputColor = "green";
            }
            {
              type = "wmtheme";
              key = " ├ 󰉼 ";
              keyColor = "green";
              outputColor = "green";
            }
            {
              type = "icons";
              key = " ├ 󰀻 ";
              keyColor = "green";
              outputColor = "green";
            }
            {
              type = "cursor";
              key = " ├  ";
              keyColor = "green";
              outputColor = "green";
            }
            {
              type = "terminalfont";
              key = " └  ";
              keyColor = "green";
              outputColor = "green";
            }
            "break"
            {
              type = "host";
              format = "{5} {2}";
              key = "HW   ";
              keyColor = "blue";
              outputColor = "blue";
            }
            {
              type = "cpu";
              key = " ├ 󰓅 ";
              keyColor = "blue";
              outputColor = "blue";
            }
            {
              type = "gpu";
              # format = "{name} [{type}]";
              key = " ├ 󰢮 ";
              keyColor = "blue";
              outputColor = "blue";
            }
            {
              type = "memory";
              key = " ├  ";
              keyColor = "blue";
              outputColor = "blue";
            }
            {
              type = "disk";
              key = " ├ 󰋊 ";
              keyColor = "blue";
              outputColor = "blue";
            }
            {
              type = "monitor";
              format = "{width}x{height} @ {refresh-rate} Hz";
              key = " └  ";
              keyColor = "blue";
              outputColor = "blue";
            }
            # {
            #   type = "player";
            #   key = " ├ 󰥠 ";
            #   keyColor = "blue";outputColor = "blue";
            # }
            # {
            #   type = "media";
            #   key = " └ 󰝚 ";
            #   keyColor = "blue";outputColor = "blue";
            # }
            "break"
            {
              type = "uptime";
              key = "   Uptime   ";
            }
          ];
        };
      };
    };
  };
}
