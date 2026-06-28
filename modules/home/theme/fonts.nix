{
  flake.modules.homeManager.theme = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.fonts;
  in {
    options.homeManager.theme.fonts = {
      enable = lib.mkEnableOption "Add more fonts to user environment";
    };

    config = lib.mkIf cfg.enable {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        maple-mono.NF
        nerd-fonts.jetbrains-mono
        nerd-fonts.noto
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        dejavu_fonts
      ];
    };
  };
}
