{
  modules.homeManager.dms = {
    inputs,
    config,
    lib,
    pkgs,
    flake,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    imports = [
      inputs.dms.homeModules.dank-material-shell
      inputs.dms-plugin-registry.homeModules.default
    ];
    options.homeManager.dms._module_marker = lib.mkOption {
      type = lib.types.bool;
      default = true;
      readOnly = true;
      internal = true;
      visible = false;
      description = "Internal: marks that this module was imported. Do not set manually.";
    };

    config = {
      home.file.".config/DankMaterialShell/settings.json".source =
        mkOutOfStoreSymlink
        "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/dms/settings.json";

      programs.dank-material-shell = {
        enable = true;
        session = {
          wallpaperTransition = "random";
          wallpaperCyclingEnabled = true;
          wallpaperCyclingRandom = true;
        };

        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)
        enableClipboardPaste = true; # Pasting items from the clipboard (wtype)

        plugins = {
          wallpaperCarousel.enable = true;
          emojiLauncher.enable = true;
        };
      };
    };
  };
}
