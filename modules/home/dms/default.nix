{
  modules.homeManager.dms = {
    inputs,
    config,
    lib,
    pkgs,
    ...
  }: {
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
      programs.dank-material-shell = {
        enable = true;
        # systemd.enable = true;
        settings = import ./_settings.nix {inherit config;};
        session = import ./_session.nix;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
