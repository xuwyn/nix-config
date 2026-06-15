{pkgs}:
pkgs.writeShellScriptBin "rofi-launcher" ''
  # check if rofi is already running
  if pidof rofi > /dev/null; then
    pkill rofi
  fi
  ${pkgs.rofi}/bin/rofi -show drun
''
