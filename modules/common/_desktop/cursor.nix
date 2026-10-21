let
  name = "Bibata-Modern-Ice";
  size = 24;
in {
  files = {
    ".icons/default/index.theme" = ''
      [Icon Theme]
      Name=Default
      Inherits=${name}
    '';
    ".Xresources" = ''
      Xcursor.theme: ${name}
      Xcursor.size: ${toString size}
    '';
  };
}
