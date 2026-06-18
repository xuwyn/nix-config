{pkgs}:
pkgs.writeShellScriptBin "polybar-launcher" ''
  if pidof polybar > /dev/null; then
    pkill polybar
  fi

  # Dynamic CPU hwmon path discovery (Intel/AMD)
  CPU_HWMON_PATH=""
  for hwmon in /sys/class/hwmon/hwmon*; do
    if [ -f "$hwmon/name" ]; then
      drv_name=$(${pkgs.coreutils}/bin/cat "$hwmon/name")
      if [ "$drv_name" = "coretemp" ] || [ "$drv_name" = "k10temp" ] || [ "$drv_name" = "zenpower" ]; then
        if [ -f "$hwmon/temp1_input" ]; then
            CPU_HWMON_PATH="$hwmon/temp1_input"
            break
        fi
      fi
    fi
  done

  # Start polybar for every connected monitors
  if type "xrandr" > /dev/null 2>&1; then
    readarray -t CONNECTED_MONITORS < <(xrandr --query | grep " connected" | cut -d" " -f1)

    for m in "''${CONNECTED_MONITORS[@]}"; do
      MONITOR="$m" CPU_HWMON_PATH="$CPU_HWMON_PATH" polybar --reload i3-bar & disown
    done
  else
    CPU_HWMON_PATH="$CPU_HWMON_PATH" polybar --reload i3-bar & disown
  fi
''
