{
  inputs,
  config,
  ...
}: let
  inherit (config.flake.modules) nixos home;
in {
  nixos.mango = {
    host = "mango";
    profile = "amd-nvidia-sync";
    username = "wyn";
    modules = [
      ./_hardware.nix
      inputs.chaotic.nixosModules.default
      nixos.boot
    ];
  };

  home."wyn@mango" = {
    system = "x86_64-linux";
    host = "mango";
    username = "wyn";
    modules = [];
  };
}
