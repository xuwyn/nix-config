{
  platforms = ["linux"];
  module = {lib, ...}: {
    hardware = {
      enableRedistributableFirmware = lib.mkDefault true;
      i2c.enable = lib.mkDefault true;
    };
    services.fstrim.enable = lib.mkDefault true; # SSD optimizer
  };
}
