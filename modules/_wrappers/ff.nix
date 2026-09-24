# fastfetch profile switcher script
{types, ...} @ adios: {
  inputs = {
    fastfetch.from = {parent}: parent.fastfetch;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  impl = {
    inputs,
    options,
  }: let
    pkgs = inputs.nixpkgs.pkgs;
    logos = import ./fastfetch/logos.nix pkgs;

    full = inputs.fastfetch {settings = import ./fastfetch/profiles/full.nix logos.frieren;};
    mini = inputs.fastfetch {settings = import ./fastfetch/profiles/mini.nix logos.nixos;};
    gif = inputs.fastfetch {settings = import ./fastfetch/profiles/mini.nix logos.onlooker;};
  in
    pkgs.writeShellScriptBin "ff" ''
      set -euo pipefail
      case "''${1:-mini}" in
        full) exec ${full}/bin/fastfetch "''${@:2}" ;;
        mini) exec ${mini}/bin/fastfetch "''${@:2}" ;;
        gif)  exec ${gif}/bin/fastfetch "''${@:2}" ;;
        *)
          echo "No such profile: $1" >&2
          echo "Available profiles: full mini gif" >&2
          exit 1
          ;;
      esac
    '';
}
