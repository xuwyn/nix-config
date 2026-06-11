{...}: {
  imports = [
    ./amdgpu.nix
    ./intelgpu.nix
    ./nvidia.nix
    ./nvidia-amd-hybrid.nix
    ./nvidia-intel-hybrid.nix
    ./vm-guest-services.nix
    ./wsl.nix
  ];
}
