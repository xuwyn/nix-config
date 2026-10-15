{
  tags = ["desktop"];
  module = {pkgs, ...}: {
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
}
