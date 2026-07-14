{
  modules.nixos.vm = {...}: {
    imports = [
      ../_drivers/vm-guest-services.nix
    ];
    # Enable GPU Drivers
    vm.guest-services.enable = true;
  };
}
