{inputs, ...}: let
  inherit (import ../modules/flake/_lib/builders.nix {inherit inputs;}) mkHomeConfig;
in {
  flake.homeConfigurations."wyn@potato" = mkHomeConfig {
    system = "x86_64-linux";
    host = "potato";
    username = "wyn";
    extraModules = [../../../hosts/capybara];
  };
}
