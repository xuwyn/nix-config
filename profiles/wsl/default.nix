{host, ...}: {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
  ];
  # Enable WSL
  drivers.wsl.enable = true;
}
