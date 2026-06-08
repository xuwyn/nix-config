{
  config,
  pkgs,
  lib,
  ...
}: let
  # Check if the current system is running an Intel or AMD CPU
  isIntel = config.hardware.cpu.intel.updateMicrocode;
  isAmd = config.hardware.cpu.amd.updateMicrocode;
in {
  boot.kernelModules =
    ["i2c-dev"]
    ++ lib.optionals isAmd ["i2c-piix4"]
    ++ lib.optionals isIntel ["i2c-i801"];

  environment.systemPackages = [pkgs.openrgb];

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb;
    motherboard =
      if isAmd
      then "amd"
      else if isIntel
      then "intel"
      else null;
  };
}
