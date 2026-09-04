{inputs, ...}: [
  # nvfetcher sources
  (final: prev: {
    sources = import ../../_sources/generated.nix {
      inherit (final) fetchFromGitHub fetchurl fetchgit dockerTools;
    };
  })

  (
    # xwayland-satellite breaks steam dropdown menu (2026-09-03)
    final: prev: let
      xwaylandSatelliteSrc = final.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        rev = "a879e5e0896a326adc79c474bf457b8b99011027";
        hash = "sha256-wToKwH7IgWdGLMSIWksEDs4eumR6UbbsuPQ42r0oTXQ=";
      };
    in {
      xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
        src = xwaylandSatelliteSrc;
        cargoDeps = final.rustPlatform.importCargoLock {
          lockFile = "${xwaylandSatelliteSrc}/Cargo.lock";
        };
      });
    }
  )

  # Firefox addons
  inputs.nur.overlays.default

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned
]
