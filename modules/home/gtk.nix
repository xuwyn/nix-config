{config, pkgs, ...}: {
  gtk = {
    gtk4.theme = null;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  xdg.configFile = {
    "gtk-3.0/gtk.css".force = true;
    "gtk-4.0/gtk.css".force = true;
  };
}
