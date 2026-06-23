{inputs, ...}: let
  inherit (import ../modules/flake/_lib/builders.nix {inherit inputs;}) mkHomeConfig;
in {
  flake.homeConfigurations."wyn@capybara" = mkHomeConfig {
    system = "x86_64-linux";
    host = "capybara";
    username = "wyn";
    extraModules = [../../../hosts/capybara];
  };
}
