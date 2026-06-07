{
  inputs,
  pkgs,
  ...
}: let
  umbrella-fetch = pkgs.rustPlatform.buildRustPackage {
    name = "umbrella-fetch";
    src = inputs.umbrella-fetch;
    cargoHash = "sha256-97dIyzOR06eJxqaEUR1d4IOaIOEcqG6RWd9YqcGIt/A=";
  };
in {
  home.packages = [
    umbrella-fetch
  ];
}
