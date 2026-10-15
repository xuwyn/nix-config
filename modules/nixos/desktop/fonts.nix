{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
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
}
