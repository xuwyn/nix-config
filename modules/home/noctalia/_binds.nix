{config, ...}: let
  noctaliaBinds = [
    {
      key = "SUPER + A";
      command = "noctalia msg panel-toggle launcher";
    }
    {
      key = "SUPER + V";
      command = "noctalia msg panel-toggle clipboard";
    }
    {
      key = "SUPER + SHIFT + V";
      command = "noctalia msg clipboard-clear";
    }
    {
      key = "SUPER + C";
      command = "noctalia msg panel-toggle control-center";
    }
    {
      key = "SUPER + CTRL + C";
      command = "noctalia msg settings-toggle";
    }
    {
      key = "SUPER + SHIFT + W";
      command = "noctalia msg panel-toggle wallpaper";
    }
    {
      key = "SUPER + N";
      command = "noctalia msg panel-toggle control-center notifications";
    }
    {
      key = "SUPER + SHIFT + N";
      command = "noctalia msg notification-clear-history";
    }
    {
      key = "SUPER + CTRL + N";
      command = "noctalia msg panel-toggle noctalia/notes:panel";
    }
    {
      key = "SUPER + E";
      command = "noctalia msg panel-toggle launcher \\\"/emo\\\"";
    }
    {
      key = "SUPER + ALT + W";
      command = "noctalia msg panel-toggle launcher \\\"/web\\\"";
    }
    {
      key = "SUPER + SHIFT + A";
      command = "noctalia msg panel-toggle launcher \\\"/win\\\"";
    }
    {
      key = "SUPER + SHIFT + E";
      command = "noctalia msg panel-toggle launcher \\\"/kao\\\"";
    }
    {
      key = "SUPER + SHIFT + T";
      command = "noctalia msg panel-toggle launcher \\\"/tr\\\"";
    }
    {
      key = "SUPER + CTRL + T";
      command = "noctalia msg panel-toggle nightwatch75/todo:panel";
    }
    {
      key = "SUPER + CTRL + S";
      command = "noctalia msg screenshot-fullscreen";
    }
    {
      key = "SUPER + SHIFT + S";
      command = "noctalia msg screenshot-region";
    }
    {
      key = "SUPER + R";
      command = "noctalia msg plugin noctalia/screen_recorder:service all toggle";
    }
    {
      key = "SUPER + SHIFT + R";
      command = "pkill noctalia; sleep 1; noctalia;";
    }
    {
      key = "CTRL + ALT + DELETE";
      command = "noctalia msg panel-toggle session";
    }
    {
      key = "XF86MonBrightnessDown";
      command = "noctalia msg brightness-down";
    }
    {
      key = "XF86MonBrightnessUp";
      command = "noctalia msg brightness-up";
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
      command = "noctalia msg session lock";
    };
in
  noctaliaBinds ++ [lockBind]
