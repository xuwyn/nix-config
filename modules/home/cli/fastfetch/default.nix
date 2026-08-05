{
  modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli.fastfetch;

    logos = {
      frieren = {
        source = ./frieren.png;
        type = "kitty-direct";
        height = 20;
        width = 26;
        padding = {
          top = 1;
          left = 0;
        };
      };
      onlooker = {
        source = ./onlooker.gif;
        type = "kitty-icat";
        padding = {
          top = 3;
          left = 0;
        };
      };
      nixos = {
        source = ./nixos.txt;
        padding = {
          top = 3;
          left = 0;
        };
      };
    };

    profiles = {
      full = import ./_full.nix {logo = logos.frieren;};
      mini = import ./_minimal.nix {logo = logos.nixos;};
      gif = import ./_minimal.nix {logo = logos.onlooker;};
    };

    profileFiles =
      lib.mapAttrs' (
        name: settings:
          lib.nameValuePair "fastfetch/profiles/${name}.jsonc" {
            text = builtins.toJSON settings;
          }
      )
      profiles;
    fetch-switcher = pkgs.writeShellScriptBin "ff" ''
      set -euo pipefail
      PROFILE_DIR="$HOME/.config/fastfetch/profiles"

      if [ "$#" -eq 0 ]; then
        exec ${pkgs.fastfetch}/bin/fastfetch
      fi

      CONFIG="$PROFILE_DIR/$1.jsonc"
      if [ ! -f "$CONFIG" ]; then
        echo "No such profile: $1" >&2
        echo "Available profiles:" >&2
        ls "$PROFILE_DIR" | sed 's/\.jsonc$//' >&2
        exit 1
      fi
      exec ${pkgs.fastfetch}/bin/fastfetch --config "$CONFIG" "''${@:2}"
    '';
  in {
    options.homeManager.cli.fastfetch = {
      enable = lib.mkEnableOption "Enable fastfetch";
      defaultProfile = lib.mkOption {
        type = lib.types.enum (builtins.attrNames profiles);
        default = "mini";
        description = "Profile used when running plain `fastfetch` with no args";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.fastfetch = {
        enable = true;
        settings = profiles.${cfg.defaultProfile};
      };

      xdg.configFile = profileFiles;
      home.packages = [fetch-switcher];
    };
  };
}
