# https://github.com/sonorahq/sonora/blob/8bac90bbd41de8dc9c7f93c9ff3c99818932f09b/nix/modules/hm/sonora.nix
{
  flakeInputs,
  types,
  ...
} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  options = {
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };
    settings = {
      type = types.attrs;
      default = adios.promise ({options}: {
        provider = "youtube";
        appearance = {
          theme =
            if options.noctaliaThemeEnabled
            then "noctalia"
            else "catppuccin/mocha";
          adaptive_theme = false;
          ambient = false;
          ambient_motion = true;
          visualizer = true;
          visualizer_style = "both";
          visualizer_absolute = true;
          player_bar_layout = "classic";
          player_bar_transparent = true;
          icons = "lucide";
          rounding = "rounded";
          blur = true;
          blur_window = true;
          font_size = 14.0;
          transparent = true;
          transparency = 0.25;
        };
      });
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };
  };

  result = adios.promise ({
    inputs,
    options,
    ...
  }: let
    pkgs = inputs.nixpkgs.pkgs;
    lib = pkgs.lib;
    sonora = flakeInputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.sonora-bin;

    generated =
      (pkgs.formats.json {}).generate "sonora-settings.json"
      ({version = 1;} // lib.recursiveUpdate options.settings options.extraSettings);

    configPath =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "$HOME/Library/Application Support/sonora/settings.json"
      else "\${XDG_CONFIG_HOME:-$HOME/.config}/sonora/settings.json";

    apply = pkgs.writeShellApplication {
      name = "sonora-apply-settings";
      runtimeInputs = [pkgs.jq];
      text = ''
        generated=$1
        dest="${configPath}"
        mkdir -p "$(dirname "$dest")"
        if [[ -f "$dest" ]]; then
          jq --indent 2 -s '.[0] * .[1]' "$dest" "$generated" > "$dest.tmp"
          mv "$dest.tmp" "$dest"
        else
          cp "$generated" "$dest"
        fi
      '';
    };
  in
    pkgs.symlinkJoin {
      name = "sonora";
      paths = [sonora];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        rm -f $out/bin/sonora
        makeWrapper ${lib.getExe sonora} $out/bin/sonora \
          --run ${lib.escapeShellArg "${lib.getExe apply} ${generated}"}
      '';
      meta = sonora.meta;
    });
}
