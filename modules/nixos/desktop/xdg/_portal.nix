{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      hyprland = {
        default = ["hyprland"];
        # zed needs these
        "org.freedesktop.portal.FileChooser" = ["gtk"];
        "org.freedesktop.portal.OpenURI" = ["gtk"];
      };
    };
  };
}
