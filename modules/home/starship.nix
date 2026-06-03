{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    presets = ["nerd-font-symbols" "bracketed-segments"];
  };
}
