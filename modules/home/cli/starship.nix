{
  flake.modules.homeManager.starship = {
    pkgs,
    lib,
    ...
  }: {
    options.homeManager.starship = {
      stylixTheme.enable = lib.mkEnableOption "Whether to apply Stylix theme for starship";
    };
    config = {
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
    };
  };
}
