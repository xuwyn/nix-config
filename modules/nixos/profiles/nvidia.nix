{
  modules.nixos.nvidia = {...}: {
    imports = [
      ../../_drivers/nvidia.nix
    ];
    # Enable GPU Drivers
    drivers.nvidia.enable = true;
  };
}
