{
  flake.modules.homeManager.gtk = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.gtk;
  in {
    options.homeManager.gtk = {
      stylixTheme.enable = lib.mkEnableOption "Whether to use stylix theme";
    };
    config = {
      gtk = {
        enable = true;
        gtk4.theme = lib.mkForce null;
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        # iconTheme = {
        #   name = "Papirus-Dark";
        #   package = pkgs.papirus-icon-theme;
        # };
      };
      # only needed if enable stylix for gtk
      xdg.configFile = {
        "gtk-3.0/gtk.css".force = cfg.stylixTheme.enable;
        "gtk-4.0/gtk.css".force = cfg.stylixTheme.enable;
      };
    };
  };
}
