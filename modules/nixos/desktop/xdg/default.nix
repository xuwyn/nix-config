{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    lib,
    ...
  }: let
    userDirs = {
      DOWNLOAD = "Downloads";
      DOCUMENTS = "Documents";
      PICTURES = "Pictures";
      MUSIC = "Music";
      VIDEOS = "Videos";
      SCREENSHOTS = "Pictures/Screenshots";
    };
  in {
    imports = [
      ./_portal.nix
      ./_mimeapps.nix
    ];

    options.custom.xdg.mimeApps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      example = {
        "image/png" = ["org.gnome.eog.desktop"];
        "image/jpeg" = ["org.gnome.eog.desktop"];
      };
    };

    config = {
      environment.systemPackages = with pkgs; [
        xdg-user-dirs
        xdg-user-dirs-gtk
      ];

      hj = {
        xdg.config.files."user-dirs.dirs".text = lib.concatLines (
          lib.mapAttrsToList (k: v: ''XDG_${k}_DIR="$HOME/${v}"'') userDirs
        );

        files = lib.mapAttrs' (_: v: lib.nameValuePair v {type = "directory";}) userDirs;
      };
    };
  };
}
