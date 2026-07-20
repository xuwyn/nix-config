{config, ...}: let
  inherit (config.homeManager.desktop) wallpaper;
  wallpaperName = builtins.baseNameOf (toString wallpaper);

  dmsBinds = [
    {
      key = "XF86MonBrightnessDown";
      command = "dms ipc call brightness decrement 5 \\\"\\\"";
    }
    {
      key = "XF86MonBrightnessUp";
      command = "dms ipc call brightness increment 5 \\\"\\\"";
    }
    {
      key = "SUPER + A";
      command = "dms ipc call spotlight toggle";
    }
    {
      key = "SUPER + CTRL + SPACE";
      command = "dms ipc call spotlight-bar toggle";
    }
    {
      key = "SUPER + V";
      command = "dms ipc call clipboard toggle";
    }
    {
      key = "SUPER + N";
      command = "dms ipc call notifications toggle";
    }
    {
      key = "SUPER + SHIFT + N";
      command = "dms ipc call notifications clearAll";
    }
    {
      key = "SUPER + CTRL + N";
      command = "dms ipc call notepad toggle";
    }
    {
      key = "SUPER + SHIFT + W";
      command = "dms ipc call plugins enable wallpaperCarousel && dms ipc wallpaperCarousel toggle";
    }
    {
      key = "CTRL + ALT + DELETE";
      command = "dms ipc call powermenu toggle";
    }
    {
      key = "SUPER + SHIFT + ESCAPE";
      command = "dms ipc call processlist toggle";
    }
    {
      key = "SUPER + C";
      command = "dms ipc call profile setImage $HOME/.face && dms ipc call dash toggle overview";
    }
    {
      key = "SUPER + SHIFT + C";
      command = "dms ipc call profile setImage $HOME/.face && dms ipc call control-center toggle";
    }
    {
      key = "SUPER + CTRL + C";
      command = "dms ipc call profile setImage $HOME/.face && dms ipc call settings toggle";
    }
    {
      key = "SUPER + SHIFT + R";
      command = "dms restart && sleep 1 && dms ipc call wallpaper set $HOME/Pictures/Wallpapers/${wallpaperName}";
    }
    {
      key = "SUPER + CTRL + S";
      command = "dms screenshot full -d ~/Pictures/Screenshots";
    }
    {
      key = "SUPER + SHIFT + S";
      command = "dms screenshot -d ~/Pictures/Screenshots";
    }
    {
      key = "SUPER + E";
      command = "dms ipc call plugins enable emojiLauncher && dms ipc call spotlight toggleQuery \\\":e\\\"";
    }
  ];
  lockBind =
    if config.homeManager.desktop.qylockEnabled
    then {
      key = "SUPER + L";
      command = "qylock-lock";
    }
    else {
      key = "SUPER + L";
      command = "dms ipc call lock lock";
    };
in
  dmsBinds ++ [lockBind]
