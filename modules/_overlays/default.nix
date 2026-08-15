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

  # missing headers for ananicy-cpp (2026-08-15)
  (final: prev: {
    ananicy-cpp = prev.ananicy-cpp.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          # fix missing <cstring> include with glibc 2.42 (https://github.com/NixOS/nixpkgs/pull/552211)
          (final.fetchpatch {
            name = "fix-cstring-include.patch";
            url = "https://gitlab.com/ananicy-cpp/ananicy-cpp/-/merge_requests/43.diff";
            hash = "sha256-drBUVh+N3KedJttzQIIA1s+38ngK9BgZFOdpxqBWV0E=";
          })
        ];
    });
  })
]
