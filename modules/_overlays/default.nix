{inputs, ...}: [
  # Firefox addons
  inputs.nur.overlays.default

  # cachyOS kernel (pinned version for cache hit)
  inputs.nix-cachyos-kernel.overlays.pinned
]
