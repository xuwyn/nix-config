{
  modules.nixos.desktop = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.nixos.desktop.qt;

    noctaliaThemeEnabled = config.nixos.desktop.noctalia.enable;
    mkAppearance = version:
      {
        custom_palette = true;
        icon_theme = "Papirus-Dark";
        standard_dialogs = "default";
      }
      // lib.optionalAttrs noctaliaThemeEnabled {
        color_scheme_path = "${config.hj.xdg.config.directory}/qt${toString version}ct/colors/noctalia.conf";
      };
  in {
    options.nixos.desktop.qt = {
      enable = lib.mkEnableOption "Enable theming for qt apps";
    };

    config = lib.mkIf cfg.enable {
      qt = {
        enable = true;
        platformTheme = "qt5ct";
      };

      # duplicated with gtk, leave it
      environment.systemPackages = [pkgs.papirus-icon-theme];

      hj.xdg.config.files = {
        "qt5ct/qt5ct.conf" = {
          generator = lib.generators.toINI {};
          value.Appearance = mkAppearance 5;
        };
        "qt6ct/qt6ct.conf" = {
          generator = lib.generators.toINI {};
          value.Appearance = mkAppearance 6;
        };
      };
    };
  };
}
