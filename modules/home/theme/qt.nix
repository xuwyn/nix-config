{
  modules.homeManager.theme = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.qt;
    isMatugenEnabled = config.programs.matugen.enable or false;
    barThemes = {
      "noctalia" = "noctalia.conf";
      "dms" = "matugen.conf";
    };
  in {
    options.homeManager.theme.qt = {
      enable = lib.mkEnableOption "Enable theming for qt apps";
      barName = lib.mkOption {
        type = lib.types.str;
        default = config.homeManager.hyprland.barName or "";
        description = "Set bar generated theme";
      };
      barTheme.enable = lib.mkEnableOption "Whether to use bar-generated theme";
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
              if cfg.barTheme.enable
              then ''
                color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/${barThemes.${cfg.barName}}
              ''
              else if isMatugenEnabled
              then ''
                color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/matugen-colors.conf
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
              if cfg.barTheme.enable
              then ''
                color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/${barThemes.${cfg.barName}}
              ''
              else if isMatugenEnabled
              then ''
                color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/matugen-colors.conf
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
