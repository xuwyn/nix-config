{
  flake.modules.homeManager.theme = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.theme.gtk;
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
      {
        gtk = {
          enable = true;
          gtk4.theme = lib.mkForce null;
        };
        xdg.configFile = {
          "gtk-3.0/gtk.css".force = true;
          "gtk-4.0/gtk.css".force = true;
        };
      }
      (lib.mkIf (!cfg.barTheme.enable) {
        stylix.targets.gtk.enable = true;
      })
      (lib.mkIf (cfg.barTheme.enable) {
        stylix.targets.gtk.enable = false;
        gtk = {
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          gtk3.extraCss = ''
            @import url("${barThemes.${cfg.barName}}");
          '';
          gtk4.extraCss = ''
            @import url("${barThemes.${cfg.barName}}");
          '';
        };
      })
    ]);
  };
}
