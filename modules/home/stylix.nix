{
  inputs,
  host,
  username,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage;
in {
  imports = [inputs.stylix.homeModules.stylix];
  stylix = {
    enable = true;
    image = stylixImage;
    opacity.terminal = 0.8;
    polarity = "dark";
    targets = {
      spicetify.enable = true;
      nixcord.enable = true;
      zed.enable = false;
      kitty = {
        enable = true;
        opacity.enable = true;
      };
      firefox = {
        enable = true;
        profileNames = [username];
      };
      # Avoid fetching GNOME Shell sources on non-GNOME systems (breaks on some remotes)
      gnome.enable = false;
      waybar.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      ghostty.enable = false;
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
