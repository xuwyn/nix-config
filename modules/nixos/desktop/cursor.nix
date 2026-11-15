{
  hjemCompat = true;
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    ...
  }: let
    inherit (config.custom.desktop) cursor;
  in {
    environment.systemPackages = [cursor.package];

    hj.files = {
      ".icons/default/index.theme".text = ''
        [Icon Theme]
        Name=Default
        Inherits=${cursor.name}
      '';
      ".Xresources".text = ''
        Xcursor.theme: ${cursor.name}
        Xcursor.size: ${cursor.size}
      '';
    };
  };
}
