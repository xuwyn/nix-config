{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    lib,
    config,
    pkgs,
    ...
  }: let
    noctaliaThemeEnabled = config.custom.desktop.noctalia.enable;

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
    qt = {
      enable = lib.mkDefault true;
      platformTheme = "qt5ct";
    };

    # duplicated with gtk, leave it
    environment.systemPackages = lib.mkIf config.qt.enable [pkgs.papirus-icon-theme];

    hj.xdg.config.files = lib.mkIf config.qt.enable {
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
}
