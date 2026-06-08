{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) amdgpuID nvidiaID;
in {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
  ];

  # Enable NVIDIA GPU driver
  drivers.nvidia.enable = true;

  # Enable AMD+NVIDIA hybrid drivers (Prime offload with AMD as primary)
  drivers.nvidia-amd-hybrid = {
    enable = true;
    mode = "sync";
    amdgpuBusId = "${amdgpuID}";
    nvidiaBusId = "${nvidiaID}";
  };
}
