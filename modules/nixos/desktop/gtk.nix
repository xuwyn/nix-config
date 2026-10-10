{
  modules.nixos.desktop = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.nixos.desktop.gtk;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursor = config.nixos.desktop.cursor;
    cursorSettings = lib.optionalAttrs cursor.enable {
      gtk-cursor-theme-name = cursor.name;
      gtk-cursor-theme-size = cursor.size;
    };
    noctaliaImport = ''@import url("noctalia.css");'';
    noctaliaThemeEnabled = config.nixos.desktop.noctalia.enable;
  in {
    options.nixos.desktop.gtk = {
      enable = lib.mkEnableOption "Enable theming for gtk apps";
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [theme.package iconTheme.package];

      hj.xdg.config.files = {
        "gtk-3.0/settings.ini" = {
          generator = lib.generators.toINI {};
          value.Settings =
            {
              gtk-theme-name = theme.name;
              gtk-icon-theme-name = iconTheme.name;
            }
            // cursorSettings;
        };
        "gtk-4.0/settings.ini" = {
          generator = lib.generators.toINI {};
          value.Settings =
            {
              gtk-theme-name = theme.name;
              gtk-icon-theme-name = iconTheme.name;
            }
            // cursorSettings;
        };

        # gtk4/libadwaita apps ignore gtk-theme-name, so import the theme's css
        "gtk-4.0/gtk.css".text = ''
          @import url("file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk.css");
          ${lib.optionalString noctaliaThemeEnabled noctaliaImport}
        '';

        # gtk3 reads the theme from settings.ini, so gtk.css is only for noctalia
        "gtk-3.0/gtk.css" = lib.mkIf noctaliaThemeEnabled {
          text = noctaliaImport;
        };
      };

      hj.files.".gtkrc-2.0".text = ''
        gtk-theme-name = "${theme.name}"
        gtk-icon-theme-name = "${iconTheme.name}"
        ${lib.optionalString cursor.enable ''
          gtk-cursor-theme-name = "${cursor.name}"
          gtk-cursor-theme-size = ${toString cursor.size}
        ''}
      '';
    };
  };
}
