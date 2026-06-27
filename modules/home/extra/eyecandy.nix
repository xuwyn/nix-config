{
  flake.modules.homeManager.eyecandy = {pkgs, ...}: {
    home.packages = with pkgs; [
      # --- Eye-candy ---
      onefetch # fastfetch for git repo
      eza # Beautiful ls replacement
      lolcat # Rainbow text
      cowsay # Fun text layout
      cmatrix # Raining text matrix
      asciiquarium-transparent # fish tank
      cbonsai # bonsai tree growing
      pipes # pipes screensaver
      fortune # pseudorandom messages
      taoup # same as fortune
    ];
  };
}
