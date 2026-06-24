{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    montserrat
    dejavu_fonts
  ];
}
