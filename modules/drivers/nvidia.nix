{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia;
in {
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # RTX 50xx requires the open kernel module
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.graphics = {
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };

    environment.variables = {
      # Change to "nvidia", "iHD" (Intel), or "radeonsi" (AMD)
      LIBVA_DRIVER_NAME = "nvidia"; # Example for Nvidia
      NVD_BACKEND = "direct"; # Required for Nvidia VA-API
    };
  };
}
