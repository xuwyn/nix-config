{
  flake.modules.nixos.wsl = {...}: {
    imports = [
      ../../_drivers/wsl.nix
    ];
    # Enable WSL
    drivers.wsl.enable = true;
  };
}
