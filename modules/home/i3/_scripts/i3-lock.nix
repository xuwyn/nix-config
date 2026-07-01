{
  pkgs,
  background,
  config,
}: let
  isStylixEnabled = config.homeManager.theme.stylix.enable or false;

  colors =
    if isStylixEnabled
    then {
      base00 = config.lib.stylix.colors.base00;
      base05 = config.lib.stylix.colors.base05;
      base06 = config.lib.stylix.colors.base06;
      base07 = config.lib.stylix.colors.base07;
      base08 = config.lib.stylix.colors.base08;
      base0B = config.lib.stylix.colors.base0B;
      base0D = config.lib.stylix.colors.base0D;
    }
    else {
      base00 = "1e1e2e"; # Base
      base05 = "cdd6f4"; # Text
      base06 = "f5e0dc"; # Rosewater
      base07 = "b4befe"; # Lavender
      base08 = "f38ba8"; # Red
      base0B = "a6e3a1"; # Green
      base0D = "89b4fa"; # Blue
    };
in
  pkgs.writeShellScriptBin "i3-lock" ''
    #!/bin/bash

    WALLPAPER=${background}
    LOCK_IMG="/tmp/lockscreen.png"

    # Darken and blur wallpaper using ImageMagick
    # Using absolute path to ensure pkgs.imagemagick works seamlessly
    ${pkgs.imagemagick}/bin/magick "$WALLPAPER" -brightness-contrast -20x0 -blur 0x5 "$LOCK_IMG"

    # Lock screen using Stylix base16 hex colors directly
    # Added opacity hex values (e.g., '00' for transparent, '88' for semi, 'ff' for solid)
    i3lock \
      --image "$LOCK_IMG" \
      --fill \
      --clock \
      --time-str="%H:%M" \
      --date-str="%A, %d %B" \
      --radius 180 \
      --ring-width 10 \
      --inside-color="#${colors.base00}33" \
      --ring-color="#${colors.base05}ff" \
      --line-color="#${colors.base00}00" \
      --keyhl-color="#${colors.base0B}ff" \
      --bshl-color="#${colors.base08}ff" \
      --separator-color="#${colors.base00}00" \
      --insidever-color="#${colors.base00}33" \
      --ringver-color="#${colors.base0D}ff" \
      --insidewrong-color="#${colors.base08}33" \
      --ringwrong-color="#${colors.base07}ff" \
      --time-color="#${colors.base07}ff" \
      --date-color="#${colors.base06}ff" \
      --verif-color="#${colors.base07}ff" \
      --wrong-color="#${colors.base07}ff" \
      --nofork
  ''
