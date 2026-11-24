{
  hjemCompat = true;
  module = {
    self,
    system,
    inputs,
    flakePath,
    pkgs,
    ...
  }: let
    packages = with self.wrapperModules.${system};
      [
        (zsh {})
        (bash {})
        (tealdeer {})
        (ns {})
        (nh {})
        inputs.nix-index-database.packages.${system}.comma-with-db
      ]
      ++ [
        (pkgs.writeShellApplication {
          name = "nix-build-iso";
          text = ''
            kind=''${1:-minimal}   # minimal | kde | cosmic
            system=''${2:-$(nix eval --impure --raw --expr builtins.currentSystem)}
            nix build "$HOME/${flakePath}#nixosConfigurations.$kind-iso-$system.config.system.build.isoImage"
          '';
        })
        (pkgs.writeShellApplication {
          name = "nix-eval"; # for now this name is safe
          text = ''
            if [ $# -lt 2 ]; then
              echo "usage: neval <nixos|darwin|hjem> <name> [nix flags, e.g. --show-trace]" >&2
              exit 1
            fi

            kind=$1
            name=$2
            shift 2

            flake="$HOME/${flakePath}"

            case "$kind" in
              nixos|darwin)
                nix eval --raw "$flake#''${kind}Configurations.\"$name\".config.system.build.toplevel.drvPath" "$@"
                echo
                ;;
              hjem)
                nix eval --json "$flake#hjemConfigurations.\"$name\"" \
                  --apply 'x: builtins.seq (builtins.stringLength (builtins.toJSON x.manifest)) (map (p: p.drvPath) x.packages)' "$@"
                ;;
              *)
                echo "unknown kind: $kind" >&2
                exit 1
                ;;
            esac
          '';
        })
        (pkgs.writeShellApplication {
          name = "nix-dry";
          runtimeInputs = [pkgs.jq pkgs.hostname];
          text = ''
            if [ $# -lt 1 ]; then
              echo "usage: nix-dry <nixos|darwin|hjem> [name] [nix flags, e.g. --show-trace]" >&2
              exit 1
            fi

            kind=$1
            shift

            # hjem targets are "user@host", the others are plain host names
            if [ "$kind" = hjem ]; then
              name="''${USER:-$(id -un)}@$(hostname)"
            else
              name=$(hostname)
            fi

            # optional explicit name; anything starting with "-" is a nix flag
            if [ $# -gt 0 ] && [[ $1 != -* ]]; then
              name=$1
              shift
            fi

            flake="$HOME/${flakePath}"

            case "$kind" in
              nixos)
                nix build "$flake#nixosConfigurations.\"$name\".config.system.build.toplevel" --dry-run "$@"
                ;;
              darwin)
                nix build "$flake#darwinConfigurations.\"$name\".system" --dry-run "$@"
                ;;
              hjem)
                mapfile -t drvs < <(
                  nix eval --json "$flake#hjemConfigurations.\"$name\"" \
                    --apply 'x:
                      let
                        manifestDrvs = builtins.attrNames (builtins.getContext (builtins.toJSON x.manifest));
                      in
                      manifestDrvs ++ map (p: p.drvPath) x.packages' \
                    | jq -r 'unique | .[] | if endswith(".drv") then . + "^*" else . end'
                )
                if [ "''${#drvs[@]}" -eq 0 ]; then
                  echo "no packages in hjemConfigurations.$name" >&2
                  exit 0
                fi
                nix build "''${drvs[@]}" --dry-run "$@"
                ;;
              *)
                echo "unknown kind: $kind" >&2
                exit 1
                ;;
            esac
          '';
        })
      ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
