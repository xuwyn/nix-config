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

  # Update firefox for eMudhra block (CVE-2026-113470) until the channel catches up (2026-10-21)
  (final: prev: {
    firefox-unwrapped =
      (import inputs.nixpkgs-firefox {
        inherit (prev.stdenv.hostPlatform) system;
        config = prev.config;
      }).firefox-unwrapped;
  })

  # build failed (2026-10-21)
  (final: prev: {
    mozc = prev.mozc.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/gui/dictionary_tool/dictionary_tool.ui \
            --replace-fail "::mozc::gui::" "mozc::gui::"
        '';
    });
  })

  # nvfetcher sources
  (final: prev: {
    sources = import ../../_sources/generated.nix {
      inherit (final) fetchFromGitHub fetchurl fetchgit dockerTools;
    };
  })

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned
]
