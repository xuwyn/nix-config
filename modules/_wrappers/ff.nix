# fastfetch profile switcher script
adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  result = adios.promise ({inputs}: let
    pkgs = inputs.nixpkgs.pkgs;
    logos = import ./fastfetch/logos.nix pkgs;
    json = pkgs.formats.json {};

    full = json.generate "full.json" (import ./fastfetch/profiles/full.nix logos.frieren);
    mini = json.generate "mini.json" (import ./fastfetch/profiles/mini.nix logos.nixos);
    nun = json.generate "mini.json" (import ./fastfetch/profiles/mini.nix logos.nun);
    gif = json.generate "gif.json" (import ./fastfetch/profiles/mini.nix logos.onlooker);
    fastfetch = pkgs.lib.getExe pkgs.fastfetch;
  in
    pkgs.writeShellScriptBin "ff" ''
      set -euo pipefail
      case "''${1:-mini}" in
        full) exec ${fastfetch} --config ${full} "''${@:2}" ;;
        mini) exec ${fastfetch} --config ${mini} "''${@:2}" ;;
        nun) exec ${fastfetch} --config ${nun} "''${@:2}" ;;
        gif)  exec ${fastfetch} --config ${gif} "''${@:2}" ;;
        *)
          echo "No such profile: $1" >&2
          echo "Available profiles: full mini nun gif" >&2
          exit 1
          ;;
      esac
    '');
}
