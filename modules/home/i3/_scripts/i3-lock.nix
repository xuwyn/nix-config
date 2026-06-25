{
  pkgs,
  background,
  config,
}:
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
    --inside-color="#${config.lib.stylix.colors.base00}33" \
    --ring-color="#${config.lib.stylix.colors.base05}ff" \
    --line-color="#${config.lib.stylix.colors.base00}00" \
    --keyhl-color="#${config.lib.stylix.colors.base0B}ff" \
    --bshl-color="#${config.lib.stylix.colors.base08}ff" \
    --separator-color="#${config.lib.stylix.colors.base00}00" \
    --insidever-color="#${config.lib.stylix.colors.base00}33" \
    --ringver-color="#${config.lib.stylix.colors.base0D}ff" \
    --insidewrong-color="#${config.lib.stylix.colors.base08}33" \
    --ringwrong-color="#${config.lib.stylix.colors.base07}ff" \
    --time-color="#${config.lib.stylix.colors.base07}ff" \
    --date-color="#${config.lib.stylix.colors.base06}ff" \
    --verif-color="#${config.lib.stylix.colors.base07}ff" \
    --wrong-color="#${config.lib.stylix.colors.base07}ff" \
    --nofork
''
