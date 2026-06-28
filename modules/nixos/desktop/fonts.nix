{
  flake.modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.fonts;
  in {
    options.nixos.desktop.fonts = {
      enable = lib.mkEnableOption "Install extra fonts system wide";
    };
    config = lib.mkIf cfg.enable {
      fonts = {
        packages = with pkgs; [
          dejavu_fonts
          fira-code
          fira-code-symbols
          font-awesome
          hackgen-nf-font
          ibm-plex
          inter
          jetbrains-mono
          material-icons
          maple-mono.NF
          minecraftia
          nerd-fonts.im-writing
          nerd-fonts.blex-mono
          nerd-fonts.iosevka-term
          nerd-fonts.lilex
          nerd-fonts.ubuntu
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-mono
          nerd-fonts.noto
          noto-fonts
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-monochrome-emoji
          powerline-fonts
          roboto
          roboto-mono
          symbola
          terminus_font
        ];
      };
    };
  };
}
