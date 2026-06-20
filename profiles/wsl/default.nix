{host, ...}: {
  imports = [
    ../../modules/drivers/wsl.nix
    ../../modules/core/system.nix
    ../../modules/core/network.nix
    ../../modules/core/services.nix
    ../../modules/core/user.nix
    ../../hosts/${host}
  ];
  # Enable WSL
  drivers.wsl.enable = true;
}
