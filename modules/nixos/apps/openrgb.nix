{
  modules.nixos.apps = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.nixos.apps.openrgb;
    # Check if the current system is running an Intel or AMD CPU
    isIntel = config.hardware.cpu.intel.updateMicrocode;
    isAmd = config.hardware.cpu.amd.updateMicrocode;
  in {
    options.nixos.apps.openrgb.enable = lib.mkEnableOption "Enable OpenRGB";
    config = lib.mkIf cfg.enable {
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
    };
  };
}
