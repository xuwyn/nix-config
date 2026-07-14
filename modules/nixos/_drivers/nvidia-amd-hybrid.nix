{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia-amd-hybrid;
in {
  options.drivers.nvidia-amd-hybrid = {
    enable = mkEnableOption "Enable AMD iGPU + NVIDIA dGPU";
    mode = mkOption {
      type = types.enum ["sync" "offload"];
      default = "sync";
      description = "Choose between Nvidia Sync (always on) or Prime Offload mode";
    };
    # AMD iGPU Bus ID (e.g., PCI:5:0:0). Expose as option for future host wiring.
    amdgpuBusId = mkOption {
      type = types.str;
      default = "PCI:5:0:0";
      description = "PCI Bus ID for AMD iGPU";
    };
    # NVIDIA dGPU Bus ID (e.g., PCI:1:0:0)
    nvidiaBusId = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID for NVIDIA dGPU";
    };
  };

  config = mkIf cfg.enable {
    hardware.nvidia = {
      # Helpful on laptops to power down the dGPU when idle
      # Enable in sync mode to fix Nvidia not waking after sleep
      powerManagement.enable = true;
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
  };
}
