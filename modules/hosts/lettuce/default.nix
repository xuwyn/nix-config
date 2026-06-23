{inputs, ...}: let
  inherit (import ../modules/flake/_lib/builders.nix {inherit inputs;}) mkNixosConfig mkHomeConfig;
in {
  flake.nixosConfigurations.lettuce = mkNixosConfig {
    system = "x86_64-linux";
    host = "lettuce";
    profile = "wsl";
    username = "wyn";
    extraModules = [inputs.nixos-wsl.nixosModules.default];
  };

  flake.homeConfigurations."wyn@lettuce" = mkHomeConfig {
    system = "x86_64-linux";
    host = "lettuce";
    username = "wyn";
  };
}
