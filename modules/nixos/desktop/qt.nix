{
  hjemCompat = true;
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    lib,
    config,
    pkgs,
    ...
  }: let
    mkAppearance = version: {
      custom_palette = true;
      icon_theme = "Papirus-Dark";
      standard_dialogs = "default";
      color_scheme_path = "${config.hj.xdg.config.directory}/qt${toString version}ct/colors/noctalia.conf";
    };
  in {
    qt = {
      enable = lib.mkDefault true;
      platformTheme = "qt5ct";
    };

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
}
