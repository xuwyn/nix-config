{
  config,
  lib,
  ...
}: let
  cfg = config.homeManager;
  inherit (cfg.desktop) bar;
  matugenEnabled = config.programs.matugen.enable or false;
  barThemes = {
    noctalia = ''
      include optional=true "noctalia.kdl"
    '';
    dms = ''
    '';
  };
in {
  wayland.windowManager.niri.extraConfig =
    ''
      ${lib.optionalString cfg.niri.barThemeEnabled (barThemes.${bar} or "")}
    ''
    + lib.optionalString (matugenEnabled && !cfg.niri.barThemeEnabled) ''
    '';
}
