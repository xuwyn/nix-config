_: let
  mkFontsModule = class: {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.${class}.desktop.fonts;
  in {
    options.${class}.desktop.fonts = {
      enable = lib.mkEnableOption "Set fonts system wide";
    };

    config = lib.mkIf cfg.enable {
      fonts.packages = with pkgs; [
        dejavu_fonts
        maple-mono.NF
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-monochrome-emoji
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];
    };
  };
in {
  modules.nixos.desktop = {
    config,
    lib,
    ...
  }: {
    imports = [(mkFontsModule "nixos")];
    config = lib.mkIf config.nixos.desktop.fonts.enable {
      fonts.fontconfig = {
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

  modules.darwin.desktop = mkFontsModule "darwin";
}
