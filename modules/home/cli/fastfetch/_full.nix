{logos, ...}: let
  colors = {
    os = "cyan";
    wm = "blue";
    hw = "dim_blue";
  };
in {
  display.separator = " ➜  ";
  logo = logos.frieren;

  modules = [
    "break"
    {
      type = "title";
      key = "OS   ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    {
      type = "os";
      key = " ├  ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    {
      type = "kernel";
      key = " ├  ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    {
      type = "packages";
      key = " ├ 󰏖 ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    {
      type = "terminal";
      key = " ├  ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    {
      type = "shell";
      key = " └  ";
      keyColor = colors.os;
      outputColor = colors.os;
    }
    "break"
    {
      type = "wm";
      key = "WM   ";
      keyColor = colors.wm;
      outputColor = colors.wm;
    }
    {
      type = "command";
      key = " ├  ";
      keyColor = colors.wm;
      text = "polybar -v | head -n 1";
      outputColor = colors.wm;
    }
    {
      type = "command";
      key = " ├ 󰏒 ";
      keyColor = colors.wm;
      text = "noctalia --version";
      outputColor = colors.wm;
    }
    {
      type = "command";
      key = " ├  ";
      keyColor = colors.wm;
      text = "dms version | cut -d'+' -f1";
      outputColor = colors.wm;
    }
    {
      type = "command";
      key = " ├  ";
      keyColor = colors.wm;
      text = "caelestia --version | awk '/caelestia-shell/ {printf \"%s v%s\\n\",$1,$2; exit}'";
      outputColor = colors.wm;
    }
    {
      type = "wmtheme";
      key = " ├ 󰉼 ";
      keyColor = colors.wm;
      outputColor = colors.wm;
    }
    {
      type = "icons";
      key = " ├ 󰀻 ";
      keyColor = colors.wm;
      outputColor = colors.wm;
    }
    {
      type = "cursor";
      key = " ├  ";
      keyColor = colors.wm;
      outputColor = colors.wm;
    }
    {
      type = "terminalfont";
      key = " └  ";
      keyColor = colors.wm;
      outputColor = colors.wm;
    }
    "break"
    {
      type = "host";
      format = "{5} {2}";
      key = "HW   ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    {
      type = "cpu";
      key = " ├  ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    {
      type = "gpu";
      key = " ├ 󰢮 ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    {
      type = "memory";
      key = " ├  ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    {
      type = "disk";
      key = " ├ 󰋊 ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    {
      type = "monitor";
      format = "{width}x{height} @ {refresh-rate} Hz";
      key = " └  ";
      keyColor = colors.hw;
      outputColor = colors.hw;
    }
    "break"
    {
      type = "uptime";
      key = "   Uptime   ";
    }
  ];
}
