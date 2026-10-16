{
  self,
  system,
  inputs,
  lib,
  pkgs,
  ...
}: let
  isDarwin = lib.hasSuffix "-darwin" system;
  nixIndexModule =
    if isDarwin
    then inputs.nix-index-database.darwinModules.nix-index
    else inputs.nix-index-database.nixosModules.default;
in {
  imports = [nixIndexModule];

  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with self.wrapperModules.${system}; [
    (zsh {})
    (bash {})
    (tealdeer {})
    (ff {})
    (ns {})
    (nh {})
    pkgs.tack
    pkgs.nvfetcher
    inputs.multiverse.packages.${pkgs.stdenv.hostPlatform.system}.mvs
  ];
}
