{
  flake.modules.homeManager.theme = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.theme.gtk;
    isMatugenEnabled = config.programs.matugen.enable or false;
    barThemes = {
      dms = "dank-colors.css";
      noctalia = "noctalia.css";
    };
  in {
    options.homeManager.theme.gtk = {
      enable = lib.mkEnableOption "Enable theming for gtk apps";
      barName = lib.mkOption {
        type = lib.types.str;
        default = config.homeManager.hyprland.barName or "";
        description = "Set bar generated theme";
      };
      barTheme.enable = lib.mkEnableOption "Whether to use bar-generated theme";
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (cfg.barName == "dms" && cfg.barTheme.enable) {
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
            if cfg.barTheme.enable
            then {
              gtk3.extraCss = ''
                @import url("${barThemes.${cfg.barName}}");
              '';
              gtk4.extraCss = ''
                @import url("${barThemes.${cfg.barName}}");
              '';
            }
            else if isMatugenEnabled
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
