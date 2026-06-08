{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) intelID nvidiaID;
in {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
  ];

  # Enable NVIDIA GPU driver
  drivers.nvidia.enable = true;

  # Enable NVIDIA/Intel hybrid driver
  drivers.nvidia-intel-hybrid = {
    enable = true;
    mode = "sync";
    intelBusID = "${intelID}";
    nvidiaBusID = "${nvidiaID}";
  };
}
