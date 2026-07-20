{inputs, ...}: [
  # nvfetcher sources
  (final: prev: {
    sources = import ../../_sources/generated.nix {
      inherit (final) fetchFromGitHub fetchurl fetchgit dockerTools;
    };
  })

  # niri-nix overlays (for cache hit)
  inputs.niri-nix.overlays.niri-nix

  # Firefox addons
  inputs.nur.overlays.default

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned

  # spicetify-cli breaks in nixpkgs unstable
  (final: prev: {
    spicetify-cli =
      (import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/67650575de1a9c27262b96b2608f7d41ae311a0b.tar.gz";
          sha256 = "00c729p8gqka57hbvsx09rxmbzc3g05pxgv0vgg5h0jcnghap3sr";
        }) {
          inherit (prev) system;
        }).spicetify-cli;
  })
]
