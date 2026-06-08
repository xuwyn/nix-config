{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaPkg = inputs.noctalia.packages.${system}.default;
in {
  # Install the Noctalia package
  home.packages = [noctaliaPkg];

  # Configure Noctalia via home module
  imports = [inputs.noctalia.homeModules.default];
  programs.noctalia = {
    enable = false; # for now
  };
}
