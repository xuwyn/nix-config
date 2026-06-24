{
  flake.modules.nixos.flatpak = {inputs, ...}: {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];
    services.flatpak = {
      enable = true;
      packages = [
      ];
      update.onActivation = true;
    };
  };
}
