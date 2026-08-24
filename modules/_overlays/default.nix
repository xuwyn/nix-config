{inputs, ...}: [
  # nvfetcher sources
  (final: prev: {
    sources = import ../../_sources/generated.nix {
      inherit (final) fetchFromGitHub fetchurl fetchgit dockerTools;
    };
  })

  # Firefox addons
  inputs.nur.overlays.default

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned
]
