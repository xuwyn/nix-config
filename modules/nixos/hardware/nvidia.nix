{
  tags = ["nvidia"];
  platforms = ["linux"];
  module = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.custom.nvidia.hybrid;
  in {
    options.custom.nvidia.hybrid = {
      enable = lib.mkEnableOption "AMD iGPU + NVIDIA dGPU";
      mode = lib.mkOption {
        type = lib.types.enum ["sync" "offload"];
        default = "sync";
        description = "Choose between Nvidia Sync (always on) or Prime Offload mode";
      };
      amdgpuBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:5:0:0";
        description = "PCI Bus ID for AMD iGPU";
      };
      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
        description = "PCI Bus ID for NVIDIA dGPU";
      };
    };

    config = lib.mkMerge [
      {
        services.xserver.videoDrivers = ["nvidia"];

        hardware.nvidia = {
          modesetting.enable = lib.mkDefault true;
          open = lib.mkDefault true; # RTX 50xx requires the open kernel module
          nvidiaSettings = lib.mkDefault true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;
          extraPackages = with pkgs; [
            nvidia-vaapi-driver
          ];
        };

        environment.variables = {
          # Enable vaapi for nvidia (unsupported)
          LIBVA_DRIVER_NAME = "nvidia";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          NVD_BACKEND = "direct";
        };
      }

      (lib.mkIf cfg.enable {
        hardware.nvidia = {
          # Helpful on laptops to power down the dGPU when idle
          # Enable in sync mode to fix Nvidia not waking after sleep
          powerManagement.enable = lib.mkDefault true;
          powerManagement.finegrained = cfg.mode == "offload";

          prime = {
            # NVIDIA primary, AMD as backup
            sync.enable = cfg.mode == "sync";

            # AMD primary, NVIDIA offload
            offload = {
              enable = cfg.mode == "offload";
              enableOffloadCmd = cfg.mode == "offload";
            };

            # Wire from options
            amdgpuBusId = cfg.amdgpuBusId;
            nvidiaBusId = cfg.nvidiaBusId;
          };
        };
      })
    ];
  };
}
