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
      # Enable vaapi for nvidia (unsupported)
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";

      # Forces the use of the NVIDIA driver for OpenGL
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      # Forces the use of the NVIDIA driver for Vulkan
      # This ensures the Vulkan loader prioritizes NVIDIA over the AMD iGPU
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

      # Optional: Helpful for some applications to recognize the GPU
      # __NV_PRIME_RENDER_OFFLOAD = "1";
    };
  };
}
