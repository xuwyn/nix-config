{
  config,
  pkgs,
  lib,
  ...
}: let
  mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configDir = "${config.home.homeDirectory}/nixos/modules/home/dotfiles";
  reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ${pkgs.procps}/bin/pgrep "Hyprland" > /dev/null; then
      ${pkgs.hyprland}/bin/hyprctl reload
    fi
  '';
in {
  home.file = {
    ".config/spicetify/config-xpui.ini".source = mkOutOfStoreSymlink "${configDir}/spicetify/config-xpui.ini";
    ".local/state/noctalia/settings.toml".source = mkOutOfStoreSymlink "${configDir}/noctalia/settings.toml";
  };

  home.activation = {
    inherit reloadHyprland;
  };
}
