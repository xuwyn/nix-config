{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.services.hardware.openrgb;
    # Check if the current system is running an Intel or AMD CPU
    isIntel = config.hardware.cpu.intel.updateMicrocode;
    isAmd = config.hardware.cpu.amd.updateMicrocode;
  in {
    services.hardware.openrgb = {
      enable = lib.mkDefault true;
      package = pkgs.openrgb;
      motherboard =
        if isAmd
        then "amd"
        else if isIntel
        then "intel"
        else null;
    };

    boot.kernelModules = lib.mkIf cfg.enable (
      ["i2c-dev"]
      ++ lib.optionals isAmd ["i2c-piix4"]
      ++ lib.optionals isIntel ["i2c-i801"]
    );

    environment.systemPackages = lib.mkIf cfg.enable [pkgs.openrgb];
  };
}
