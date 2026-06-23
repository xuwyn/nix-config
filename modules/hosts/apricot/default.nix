{inputs, ...}: let
  inherit (import ../modules/flake/_lib/builders.nix {inherit inputs;}) mkHomeConfig;
in {
  flake.homeConfigurations."wyn@apricot" = mkHomeConfig {
    system = "aarch64-darwin";
    host = "apricot";
    username = "wyn";
    extraModules = [inputs.mac-app-util.homeManagerModules.default];
  };
}
