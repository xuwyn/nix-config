{
  flake.modules.nixos.amd-nvidia-sync = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.amd-nvidia-sync;
  in {
    options.nixos.amd-nvidia-sync = {
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
      ../../_drivers/nvidia.nix
      ../../_drivers/nvidia-amd-hybrid.nix
    ];

    config = {
      # Enable NVIDIA GPU driver
      drivers.nvidia.enable = true;

      # Enable AMD+NVIDIA hybrid drivers (sync NVIDIA and AMD)
      drivers.nvidia-amd-hybrid = {
        enable = true;
        mode = "sync";
        amdgpuBusId = "${cfg.amdgpuID}";
        nvidiaBusId = "${cfg.nvidiaID}";
      };
    };
  };
}
