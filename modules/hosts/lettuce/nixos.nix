{config, ...}: {
  nixos.lettuce = {
    system = "x86_64-linux";
    users = ["wyn"];
    modules = with config.modules.nixos;
      [nix-settings drivers system]
      ++ [
        (_: {
          nixos.drivers.wsl.enable = true;
        })
      ];
  };
}
