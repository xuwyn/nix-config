{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia-intel-hybrid;
in {
  options.drivers.nvidia-intel-hybrid = {
    enable = mkEnableOption "Enable Intel iGPU + NVIDIA dGPU";
    mode = mkOption {
      type = types.enum ["sync" "offload"];
      default = "sync";
      description = "Choose between Nvidia Sync (always on) or Prime Offload mode";
    };
    intelBusID = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
    };
    nvidiaBusID = mkOption {
      type = types.str;
      default = "PCI:0:2:0";
    };
  };

  config = mkIf cfg.enable {
    hardware.nvidia = {
      # Helpful on laptops to power down the dGPU when idle
      # Enable in sync mode to fix Nvidia not waking after sleep
      powerManagement.enable = true;
      powerManagement.finegrained = cfg.mode == "offload";

      prime = {
        # NVIDIA primary, Intel as backup
        sync.enable = cfg.mode == "sync";

        # Intel primary, NVIDIA offload
        offload = {
          enable = cfg.mode == "offload";
          enableOffloadCmd = cfg.mode == "offload";
        };

        # Make sure to use the correct Bus ID values for your system!
        intelBusId = "${cfg.intelBusID}";
        nvidiaBusId = "${cfg.nvidiaBusID}";
      };
    };
  };
}
