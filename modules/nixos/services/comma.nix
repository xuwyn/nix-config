{inputs, ...}: {
  flake.modules.nixos.comma = {
    # comma already included in home.nix
    # only use this if running nixos without home
    imports = [inputs.nix-index-database.nixosModules.default];
    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
