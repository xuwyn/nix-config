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

  # patching this way is not IFD 😆
  (final: prev: {
    microfetch = inputs.microfetch.packages.${final.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [../../patches/microfetch-logo.patch];
    });
  })
]
