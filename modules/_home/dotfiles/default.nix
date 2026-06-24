{
  config,
  pkgs,
  lib,
  host,
  ...
}: let
  mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configDir = "${config.home.homeDirectory}/nixos/modules/home/dotfiles";
  reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ${pkgs.procps}/bin/pgrep "Hyprland" > /dev/null; then
      ${pkgs.hyprland}/bin/hyprctl reload
    fi
  '';
  vars = import ../../../hosts/${host}/variables.nix;
  i3Enable = vars.i3Enable or false;
in {
  home.file =
    {
      ".local/state/noctalia/settings.toml".source = mkOutOfStoreSymlink "${configDir}/noctalia/settings.toml";
      ".config/kitty/themes".source = mkOutOfStoreSymlink "${configDir}/kitty/themes";
      ".config/btop/themes".source = mkOutOfStoreSymlink "${configDir}/btop/themes";
      ".config/cava/themes".source = mkOutOfStoreSymlink "${configDir}/cava/themes";
      ".config/Equicord/themes".source = mkOutOfStoreSymlink "${configDir}/Equicord/themes";
      ".config/hypr/noctalia.conf".source = mkOutOfStoreSymlink "${configDir}/hypr/noctalia.conf";
      ".config/hypr/noctalia.lua".source = mkOutOfStoreSymlink "${configDir}/hypr/noctalia.lua";
    }
    // (
      if i3Enable
      then {".config/polybar".source = mkOutOfStoreSymlink "${configDir}/polybar";}
      else {}
    );

  home.activation = {
    inherit reloadHyprland;
  };
}
