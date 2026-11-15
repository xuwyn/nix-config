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
      ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
