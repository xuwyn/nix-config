{
  modules.nixos.intel = {...}: {
    imports = [
      ../../_drivers/intelgpu.nix
    ];
    # Enable GPU Drivers
    drivers.intelgpu.enable = true;
  };
}
