{
  modules.homeManager.theme = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.qt;
    matugenEnabled = config.programs.matugen.enable or false;
    bar = config.homeManager.desktop.bar or null;

    barThemes = {
      "noctalia" = "noctalia";
      "dms" = "matugen";
    };

    themeName =
      if cfg.barThemeEnabled
      then barThemes.${bar}
      else if matugenEnabled
      then "matugen-colors"
      else null;

    commonAppearance = {
      custom_palette = true;
      icon_theme = "Papirus-Dark";
      standard_dialogs = "default";
    };
  in {
    options.homeManager.theme.qt = {
      enable = lib.mkEnableOption "Enable theming for qt apps";
      barThemeEnabled = lib.mkOption {
        type = lib.types.bool;
        default = config.homeManager.desktop.barThemeEnabled or false;
      };
    };

    config = lib.mkIf cfg.enable {
      qt = {
        enable = true;
        platformTheme.name = "qtct";

        qt5ctSettings.Appearance =
          commonAppearance
          // lib.optionalAttrs (themeName != null) {
            color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/${themeName}.conf";
          };

        qt6ctSettings.Appearance =
          commonAppearance
          // lib.optionalAttrs (themeName != null) {
            color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/${themeName}.conf";
          };
      };
    };
  };
}
