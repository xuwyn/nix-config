{
  flake.modules.homeManager.dotfiles = {
    config,
    pkgs,
    lib,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    configDir = "${config.home.homeDirectory}/nix-config/modules/home/dotfiles";
    reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ${pkgs.procps}/bin/pgrep "Hyprland" > /dev/null; then
        ${pkgs.hyprland}/bin/hyprctl reload
      fi
    '';
  in {
    home.file = {
      "Pictures/Wallpapers" = {
        source = ../../../wallpapers;
        force = true;
      };
      ".face".source = ../face.jpg;
      ".local/state/noctalia/settings.toml".source = mkOutOfStoreSymlink "${configDir}/noctalia/settings.toml";
      ".config/kitty/themes".source = mkOutOfStoreSymlink "${configDir}/kitty/themes";
      ".config/hypr/noctalia.lua".source = mkOutOfStoreSymlink "${configDir}/hypr/noctalia.lua";
    };

    home.activation = lib.mkIf (config.homeManager.hyprland.enable or false) {
      inherit reloadHyprland;
    };
  };
}
