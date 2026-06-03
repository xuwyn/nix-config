{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "35";
          output = "95";
        };
        separator = " ➜  ";
      };

      logo = {
        source = ./nixos.png;
        type = "kitty-direct";
        height = 10;
        width = 20;
        padding = {
          top = 2;
          left = 2;
        };
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS   ";
          keyColor = "31";
        }
        # {
        #   type = "command";
        #   key = " ├  ZaneyOS ";
        #   keyColor = "31";
        #   text = "echo v$" + "{ZANEYOS_VERSION}";
        # }
        {
          type = "command";
          key = " ├ 󰏒 ";
          keyColor = "31";
          text = "noctalia --version";
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "31";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "31";
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "31";
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = "32";
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = "32";
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = "32";
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "32";
        }
        "break"
        {
          type = "host";
          format = "{5} {2}";
          key = "PC   ";
          keyColor = "33";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "gpu";
          format = "{vendor} {name}";
          key = " ├ 󰢮 ";
          keyColor = "33";
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "33";
        }
        {
          type = "monitor";
          format = "{width}x{height} ({inch} in) @ {refresh-rate} Hz";
          key = " └  ";
          keyColor = "33";
        }
        # {
        #   type = "player";
        #   key = " ├ 󰥠 ";
        #   keyColor = "33";
        # }
        # {
        #   type = "media";
        #   key = " └ 󰝚 ";
        #   keyColor = "33";
        # }
        "break"
        {
          type = "uptime";
          key = "   Uptime   ";
        }
      ];
    };
  };
}
