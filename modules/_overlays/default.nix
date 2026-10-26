{inputs, ...}: let
  multiverseOverlays = pkgs: final: prev:
    builtins.listToAttrs (map
      (p: {
        name = p.name;
        value = inputs.multiverse.multiverse.${final.stdenv.hostPlatform.system}.version p.name p.version;
      })
      pkgs);
in [
  (multiverseOverlays [])

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned
]
