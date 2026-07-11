{
  modules.nixos.intel-nvidia-sync = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.intel-nvidia-sync;
  in {
    options.nixos.intel-nvidia-sync = {
      intelID = lib.mkOption {
        type = lib.types.str;
        description = "Intel iGPU PCI address";
      };
      nvidiaID = lib.mkOption {
        type = lib.types.str;
        description = "NVIDIA dGPU PCI address";
      };
    };

    imports = [
      ../../_drivers/nvidia.nix
      ../../_drivers/nvidia-intel-hybrid.nix
    ];

    config = {
      # Enable NVIDIA GPU driver
      drivers.nvidia.enable = true;

      # Enable NVIDIA/Intel hybrid driver
      drivers.nvidia-intel-hybrid = {
        enable = true;
        mode = "sync";
        intelBusID = "${cfg.intelID}";
        nvidiaBusID = "${cfg.nvidiaID}";
      };
    };
  };
}
