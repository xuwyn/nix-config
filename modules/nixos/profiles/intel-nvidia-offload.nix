{
  modules.nixos.intel-nvidia-offload = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.intel-nvidia-offload;
  in {
    options.nixos.intel-nvidia-offload = {
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
        mode = "offload";
        intelBusID = "${cfg.intelID}";
        nvidiaBusID = "${cfg.nvidiaID}";
      };
    };
  };
}
