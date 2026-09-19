{inputs, ...}: let
  multiverseOverlays = pkgs: final: prev:
    builtins.listToAttrs (map
      (p: {
        name = p.name;
        value = inputs.multiverse.multiverse.${final.stdenv.hostPlatform.system}.version p.name p.version;
      })
      pkgs);
in [
  (multiverseOverlays [
    {
      # This is fixed upstream but not released on nixpkgs yet (2026-09-12)
      name = "xwayland-satellite";
      version = "0.8.1";
    }
  ])

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

  # rs-key patch for ccid-rs-key
  inputs.rs-key.overlays.ccid-rs-key
]
