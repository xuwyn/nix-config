{
  pkgs,
  ...
}: let
  inherit (config.homeManager.i3) monitors;
  genBashArray = builtins.map (m: "REFRESH_RATES[\"${m.name}\"]=\"${m.refreshRate}\"") monitors;
  bashArrayLines = builtins.concatStringsSep "\n" genBashArray;
in
  pkgs.writeShellScriptBin "set-refresh-rates" ''
    # Declare a native Bash Associative Array
    declare -A REFRESH_RATES
    ${bashArrayLines}

    if type "xrandr" > /dev/null 2>&1; then
      # Pull connected monitors into an array safely
      readarray -t CONNECTED_MONITORS < <(xrandr --query | grep " connected" | cut -d" " -f1)

      for m_name in "''${!REFRESH_RATES[@]}"; do
        m_rate="''${REFRESH_RATES[$m_name]}"

        for connected in "''${CONNECTED_MONITORS[@]}"; do
          if [ "$connected" = "$m_name" ]; then
            # Get the active resolution mode (marked by the * symbol)
            current_mode=$(xrandr --query | grep -A 10 "^$m_name connected" | grep '\*' | awk '{print $1}')

            if [ -n "$current_mode" ]; then
              # Apply both mode and rate together to force the hardware shift
              xrandr --output "$m_name" --mode "$current_mode" --rate "$m_rate"
            fi
            break
          fi
        done
      done
    fi
  ''
