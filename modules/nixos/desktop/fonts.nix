{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.fonts;
  in {
    options.nixos.desktop.fonts = {
      enable = lib.mkEnableOption "Set fonts system wide";
    };
    config = lib.mkIf cfg.enable {
      fonts = {
        packages = with pkgs; [
          dejavu_fonts
          jetbrains-mono
          maple-mono.NF
          nerd-fonts.jetbrains-mono
          nerd-fonts.noto
          noto-fonts
          noto-fonts-monochrome-emoji
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            sansSerif = ["Noto Sans"];
            serif = ["Noto Serif"];
            monospace = ["Noto Sans Mono"];
            emoji = ["Noto Color Emoji"];
          };
        };
      };
    };
  };
}
