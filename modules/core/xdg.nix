{
  pkgs,
  inputs,
  ...
}: {
  xdg = {
    portal = {
      enable = true;
      configPackages = [inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland];
      extraPortals = [ # no need to add xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          # Use the GTK portal for file pickers, and hyprland for everything else
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.FileDialog" = ["gtk"];
        };
      };
    };
  };
}
