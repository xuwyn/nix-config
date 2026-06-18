{pkgs}:
pkgs.writeShellScriptBin "media-status" ''
  player_status="$(${pkgs.playerctl}/bin/playerctl status 2> /dev/null)"

  if [[ "$player_status" = "Playing" || "$player_status" = "Paused" ]]; then
      echo "$(${pkgs.playerctl}/bin/playerctl metadata artist) - $(${pkgs.playerctl}/bin/playerctl metadata title)"
  else
      echo ""
  fi
''
