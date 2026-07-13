{
  modules.homeManager.theme = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.theme.cursor;
  in {
    options.homeManager.theme.cursor = {
      enable = lib.mkEnableOption "Enable Custom Cursor";
    };
    config = lib.mkIf cfg.enable {
      home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
  };
}
