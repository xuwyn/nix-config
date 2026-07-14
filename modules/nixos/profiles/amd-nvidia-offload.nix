{
  modules.nixos.amd-nvidia-offload = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.amd-nvidia-offload;
  in {
    options.nixos.amd-nvidia-offload = {
      amdgpuID = lib.mkOption {
        type = lib.types.str;
        description = "AMD iGPU PCI address";
      };
      nvidiaID = lib.mkOption {
        type = lib.types.str;
        description = "NVIDIA dGPU PCI address";
      };
    };
    imports = [
      ../_drivers/nvidia.nix
      ../_drivers/nvidia-amd-hybrid.nix
    ];

    config = {
      # Enable NVIDIA GPU driver
      drivers.nvidia.enable = true;

      # Enable AMD+NVIDIA hybrid drivers (Prime offload with AMD as primary)
      drivers.nvidia-amd-hybrid = {
        enable = true;
        mode = "offload";
        amdgpuBusId = "${cfg.amdgpuID}";
        nvidiaBusId = "${cfg.nvidiaID}";
      };
    };
  };
}
