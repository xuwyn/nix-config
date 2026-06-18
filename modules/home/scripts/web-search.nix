{pkgs}:
pkgs.writeShellScriptBin "web-search" ''
  # check if rofi is already running
  if pidof rofi > /dev/null; then
    pkill rofi
  fi

  # 1. Define standard indexed arrays to preserve your exact order
  PLATFORMS=(
    "🌎 Search"
    "❄️ Nix Packages (Unstable)"
    "❄️ NixOS Options (Unstable)"
    "🏠 Home Manager Options (Unstable)"
    "🎞️ YouTube"
    "🦥 Arch Wiki"
    "🐃 Gentoo Wiki"
  )

  URLS=(
    "https://www.google.com/search?q="
    "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query="
    "https://search.nixos.org/options?channel=unstable&query="
    "https://home-manager-options.extranix.com/?release=master&query="
    "https://www.youtube.com/results?search_query="
    "https://wiki.archlinux.org/title/"
    "https://wiki.gentoo.org/index.php?title="
  )

  # List for rofi loops over the keys sequentially
  gen_list() {
    for item in "''${PLATFORMS[@]}"
    do
      echo "$item"
    done
  }

  main() {
    # Pass the list to rofi
    platform=$( (gen_list) | ${pkgs.rofi}/bin/rofi -dmenu -config ~/.config/rofi/config-long.rasi )

    if [[ -n "$platform" ]]; then
      # Find the index of the selected platform to match it with its URL
      index=-1
      for i in "''${!PLATFORMS[@]}"; do
         if [[ "''${PLATFORMS[$i]}" == "$platform" ]]; then
             index=$i
             break
         fi
      done

      if [[ $index -eq -1 ]]; then
        exit 1
      fi

      query=$( (echo ) | ${pkgs.rofi}/bin/rofi -dmenu -config ~/.config/rofi/config-long.rasi )

      if [[ -n "$query" ]]; then
        url=''${URLS[$index]}$query
        xdg-open "$url"
      else
        exit
      fi
    else
      exit
    fi
  }

  main

  exit 0
''
