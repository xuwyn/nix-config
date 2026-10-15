{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.custom.cursor;
  in {
    options.custom.cursor = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Bibata-Modern-Ice";
        description = "Cursor theme name.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bibata-cursors;
        description = "Cursor theme package.";
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size in pixels.";
      };
    };

    config = {
      environment.systemPackages = [cfg.package];
      environment.sessionVariables = {
        XCURSOR_THEME = cfg.name;
        XCURSOR_SIZE = toString cfg.size;
      };

      hj.files = {
        ".icons/default/index.theme".text = ''
          [Icon Theme]
          Name=Default
          Inherits=${cfg.name}
        '';
        ".Xresources".text = ''
          Xcursor.theme: ${cfg.name}
          Xcursor.size: ${toString cfg.size}
        '';
      };
    };
  };
}
