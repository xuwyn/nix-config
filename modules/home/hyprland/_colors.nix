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
      local ok, noctalia_theme = pcall(require, "noctalia")
      if ok and noctalia_theme then
        noctalia_theme.apply_theme()
      end
    '';
    dms = ''
      require("dms.colors")
    '';
  };
in {
  wayland.windowManager.hyprland.extraConfig =
    ''
      ${lib.optionalString cfg.hyprland.barThemeEnabled (barThemes.${bar} or "")}
    ''
    + lib.optionalString (matugenEnabled && !cfg.hyprland.barThemeEnabled) ''
      local colors_path = os.getenv("HOME") .. "/.config/hypr/matugen.lua"
      local ok, colors = pcall(dofile, colors_path)
      if not ok then colors = nil end

      if colors then
        hl.config({
          general = {
            col = {
              active_border = colors.primary,
              inactive_border = colors.surface_container_lowest
            }
          }
        })
      end
    '';
}
