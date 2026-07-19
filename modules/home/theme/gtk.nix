{
  modules.homeManager.theme = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.theme.gtk;
    matugenEnabled = config.programs.matugen.enable or false;
    bar = config.homeManager.desktop.bar or null;
    barThemes = {
      dms = "dank-colors.css";
      noctalia = "noctalia.css";
    };
  in {
    options.homeManager.theme.gtk = {
      enable = lib.mkEnableOption "Enable theming for gtk apps";
      barThemeEnabled = lib.mkOption {
        type = lib.types.bool;
        default = config.homeManager.desktop.barThemeEnabled or false;
      };
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (bar == "dms" && cfg.barThemeEnabled) {
        xdg.configFile = {
          "gtk-3.0/gtk.css".force = true;
          "gtk-4.0/gtk.css".force = true;
        };
      })
      {
        gtk =
          {
            enable = true;
            gtk4.theme = lib.mkForce null;
            gtk2.theme = {
              name = "adw-gtk3-dark";
              package = pkgs.adw-gtk3;
            };
            gtk3.theme = {
              name = "adw-gtk3-dark";
              package = pkgs.adw-gtk3;
            };
            iconTheme = {
              package = pkgs.papirus-icon-theme;
              name = "Papirus-Dark";
            };
          }
          // (
            if cfg.barThemeEnabled
            then {
              gtk3.extraCss = ''
                @import url("${barThemes.${bar}}");
              '';
              gtk4.extraCss = ''
                @import url("${barThemes.${bar}}");
              '';
            }
            else if matugenEnabled
            then {
              gtk3.extraCss = ''
                @import url("matugen-colors.css");
              '';
              gtk4.extraCss = ''
                @import url("matugen-colors.css");
              '';
            }
            else {}
          );
      }
    ]);
  };
}
