{inputs, ...}: {
  flake.modules.homeManager.eyecandy = {pkgs, ...}: let
    umbrella-fetch = pkgs.rustPlatform.buildRustPackage {
      name = "umbrella-fetch";
      src = inputs.umbrella-fetch;
      cargoHash = "sha256-97dIyzOR06eJxqaEUR1d4IOaIOEcqG6RWd9YqcGIt/A=";
    };
  in {
    home.packages = with pkgs; [
      # --- Eye-candy ---
      onefetch # fastfetch for git repo
      lolcat # Rainbow text
      cowsay # Fun text layout
      cmatrix # Raining text matrix
      asciiquarium-transparent # fish tank
      cbonsai # bonsai tree growing
      pipes # pipes screensaver
      fortune # pseudorandom messages
      taoup # same as fortune
      umbrella-fetch # custom fetch RE theme
    ];
  };
}
