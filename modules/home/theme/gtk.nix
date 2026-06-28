{
  flake.modules.homeManager.theme = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.gtk;
    isStylixEnabled = config.homeManager.theme.stylix.enable or false;
  in {
    options.homeManager.theme.gtk = {
      enable = lib.mkEnableOption "Enable theming for gtk apps";
      stylixTheme.enable = lib.mkEnableOption "Whether to use stylix theme";
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        gtk = {
          enable = true;
          gtk4.theme = lib.mkForce null;
          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
          gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
      }
      (lib.mkIf (isStylixEnabled && (config ? stylix)) {
        stylix.targets.gtk.enable = cfg.stylixTheme.enable;
        xdg.configFile = {
          "gtk-3.0/gtk.css".force = cfg.stylixTheme.enable;
          "gtk-4.0/gtk.css".force = cfg.stylixTheme.enable;
        };
      })
    ]);
  };
}
