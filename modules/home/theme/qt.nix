{
  flake.modules.homeManager.theme = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.qt;
    isStylixEnabled = config.homeManager.theme.stylix.enable or false;
  in {
    options.homeManager.theme.qt = {
      enable = lib.mkEnableOption "Enable theming for qt apps";
      stylixTheme.enable = lib.mkEnableOption "Whether to enable stylix theme for qt apps";
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        qt = {
          enable = true;
          platformTheme.name = lib.mkForce "qtct";
        };
      }
      (lib.mkIf (isStylixEnabled && (config ? stylix)) {
        stylix.targets.qt = {
          enable = cfg.stylixTheme.enable;
          platform = "qtct";
        };
      })
    ]);
  };
}
