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
      "noctalia" = "noctalia.conf";
      "dms" = "matugen.conf";
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
      };
      xdg.configFile = {
        "qt5ct/qt5ct.conf" = {
          text = ''
            [Appearance]
            ${
              if cfg.barThemeEnabled
              then ''
                color_scheme_path="$HOME/.config/qt5ct/colors/${barThemes.${bar}}"
              ''
              else if matugenEnabled
              then ''
                color_scheme_path="$HOME/.config/qt5ct/colors/matugen-colors.conf"
              ''
              else ''''
            }
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
          '';
          force = true;
        };
        "qt6ct/qt6ct.conf" = {
          text = ''
            [Appearance]
            ${
              if cfg.barThemeEnabled
              then ''
                color_scheme_path="$HOME/.config/qt6ct/colors/${barThemes.${bar}}"
              ''
              else if matugenEnabled
              then ''
                color_scheme_path="$HOME/.config/qt6ct/colors/matugen-colors.conf"
              ''
              else ''''
            }
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
          '';
          force = true;
        };
      };
    };
  };
}
