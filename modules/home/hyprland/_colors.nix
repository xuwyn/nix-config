{
  config,
  lib,
  ...
}: let
  cfg = config.homeManager.hyprland;
  isMatugenEnabled = config.programs.matugen.enable or false;
  barThemes = {
    noctalia = ''
      local ok, noctalia_theme = pcall(require, "noctalia")
      if ok and noctalia_theme then
        noctalia_theme.apply_theme()
      end
    '';
    dms = ''
      local ok, err = pcall(function()
        local path = os.getenv("HOME") .. "/.config/hypr/dms/colors.conf"
        local f = io.open(path, "r")
        if not f then return end

        local vars = {}
        for line in f:lines() do
          local name, hex = line:match("^%s*%$(%w+)%s*=%s*rgb%((%x+)%)")
          if name then
            vars[name] = "rgb(" .. hex .. ")"
          end
        end
        f:close()

        if not (vars.primary and vars.outline and vars.error) then
          return
        end

        hl.config({
          general = {
            col = {
              active_border   = vars.primary,
              inactive_border = vars.outline,
            },
          },
          group = {
            col = {
              border_active          = vars.primary,
              border_inactive        = vars.outline,
              border_locked_active   = vars.error,
              border_locked_inactive = vars.outline,
            },
            groupbar = {
              col = {
                active         = vars.primary,
                inactive       = vars.outline,
                locked_active  = vars.error,
                locked_inactive = vars.outline,
              },
            },
          },
        })
      end)
    '';
  };
in {
  wayland.windowManager.hyprland.extraConfig =
    ''
      ${lib.optionalString cfg.barTheme.enable (barThemes.${cfg.barName} or "")}
    ''
    + lib.optionalString (isMatugenEnabled && !cfg.barTheme.enable) ''
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
