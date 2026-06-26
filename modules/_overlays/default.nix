{inputs, ...}: [
  # Firefox addons
  inputs.nur.overlays.default

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned

  # Build tumbler without EPUB thumbnailer (libgepub) to avoid webkitgtk
  (_final: prev: {
    xfce =
      prev.xfce
      // {
        tumbler = prev.xfce.tumbler.overrideAttrs (old: {
          buildInputs = prev.lib.remove prev.libgepub old.buildInputs;
        });
      };
  })
]
