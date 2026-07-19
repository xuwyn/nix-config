{
  pkgs,
  wallpaper,
  config,
}: let
  matugenEnabled = config.programs.matugen.enable or false;
  colors =
    if matugenEnabled
    then {
      base00 = config.programs.matugen.theme.colors.surface.default.color;
      base05 = config.programs.matugen.theme.colors.on_surface.default.color;
      base06 = config.programs.matugen.theme.colors.on_surface_variant.default.color;
      base07 = config.programs.matugen.theme.colors.tertiary.default.color;
      base08 = config.programs.matugen.theme.colors.error.default.color;
      base0B = config.programs.matugen.theme.colors.secondary.default.color;
      base0D = config.programs.matugen.theme.colors.primary.default.color;
    }
    else {
      base00 = "1e1e2e";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base0B = "a6e3a1";
      base0D = "89b4fa";
    };
in
  pkgs.writeShellScriptBin "i3-lock" ''
    #!/bin/bash

    WALLPAPER=${wallpaper}
    LOCK_IMG="/tmp/lockscreen.png"

    # Darken and blur wallpaper using ImageMagick
    # Using absolute path to ensure pkgs.imagemagick works seamlessly
    ${pkgs.imagemagick}/bin/magick "$WALLPAPER" -brightness-contrast -20x0 -blur 0x5 "$LOCK_IMG"

    # Lock screen using Matugen base16 hex colors directly
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
