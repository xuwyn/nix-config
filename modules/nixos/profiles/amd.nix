{
  modules.nixos.amd = {...}: {
    imports = [
      ../_drivers/amdgpu.nix
    ];
    # Enable GPU Drivers
    drivers.amdgpu.enable = true;
  };
}
