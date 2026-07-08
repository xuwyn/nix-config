{
  flake.modules.homeManager.theme = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.qt;
  in {
    options.homeManager.theme.qt = {
      enable = lib.mkEnableOption "Enable theming for qt apps";
      stylixTheme.enable = lib.mkEnableOption "Whether to enable stylix theme for qt apps";
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        qt.enable = true;
      }
      (lib.mkIf (config ? stylix && cfg.stylixTheme.enable) {
        qt.platformTheme.name = "qtct";
        stylix.targets.qt.enable = true;
        xdg.configFile = {
          "qt5ct/qt5ct.conf".force = true;
          "qt6ct/qt6ct.conf".force = true;
        };
      })
      (lib.mkIf (!cfg.stylixTheme.enable) {
        qt.platformTheme.name = "gtk3";
        stylix.targets.qt.enable = false;
      })
    ]);
  };
}
