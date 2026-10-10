{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.cursor;
  in {
    options.nixos.desktop.cursor = {
      enable = lib.mkEnableOption "Set the pointer cursor";
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

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];
      environment.sessionVariables = {
        XCURSOR_THEME = cfg.name;
        XCURSOR_SIZE = toString cfg.size;
      };

      hj = {
        files.".icons/default/index.theme".text = ''
          [Icon Theme]
          Name=Default
          Inherits=${cfg.name}
        '';
        files.".Xresources".text = ''
          Xcursor.theme: ${cfg.name}
          Xcursor.size: ${toString cfg.size}
        '';
      };
    };
  };
}
