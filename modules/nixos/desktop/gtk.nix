{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    lib,
    config,
    pkgs,
    ...
  }: let
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursor = config.custom.cursor;
    noctaliaImport = ''@import url("noctalia.css");'';
    noctaliaThemeEnabled = config.custom.desktop.noctalia.enable;

    settings = {
      gtk-theme-name = theme.name;
      gtk-icon-theme-name = iconTheme.name;
      gtk-cursor-theme-name = cursor.name;
      gtk-cursor-theme-size = cursor.size;
    };
  in {
    environment.systemPackages = [theme.package iconTheme.package];

    hj.xdg.config.files = {
      "gtk-3.0/settings.ini" = {
        generator = lib.generators.toINI {};
        value.Settings = settings;
      };
      "gtk-4.0/settings.ini" = {
        generator = lib.generators.toINI {};
        value.Settings = settings;
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
      gtk-cursor-theme-name = "${cursor.name}"
      gtk-cursor-theme-size = ${toString cursor.size}
    '';
  };
}
