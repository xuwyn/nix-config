{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    presets = ["nerd-font-symbols" "bracketed-segments"];
    settings = {
      scan_timeout = 250; #ms
    };
  };
}
