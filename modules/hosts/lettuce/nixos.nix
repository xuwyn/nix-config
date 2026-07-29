{config, ...}: {
  nixos.lettuce = {
    system = "x86_64-linux";
    users = ["wyn"];
    modules = with config.modules.nixos; [
      drivers
      network
      security
      system
      (_: {
        nixos.drivers.wsl.enable = true;
      })
    ];
  };
}
