{host, ...}: {
  imports = [
    ../../modules/drivers
    ../../modules/core/system.nix
    ../../modules/core/network.nix
    ../../modules/core/services.nix
    ../../modules/core/user.nix
    ../../modules/core/nh.nix
  ];
  # Enable WSL
  drivers.wsl.enable = true;
}
