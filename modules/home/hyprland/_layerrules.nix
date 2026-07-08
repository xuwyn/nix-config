{
  config,
  lib,
  ...
}: let
  cfg = config.homeManager.hyprland;

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
  wayland.windowManager.hyprland.extraConfig = ''
    -- Noctalia Blur
    hl.layer_rule({
      name = "noctalia",
      match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
      },
      no_anim = true,
      ignore_alpha = 0.5,
      blur = true,
      blur_popups = true,
    })

    -- DankMaterialShell Animation
    hl.layer_rule({
      match = {
        namespace = "dms:control-center",
      },
      animation = "slide right",
    })

    hl.layer_rule({
      match = {
        namespace = "dms:dash",
      },
      animation = "slide right",
    })

    -- DankMaterialShell Blur
    hl.layer_rule({
      match = {
        namespace = "dms:(color-picker|clipboard|spotlight|settings)",
      },
      blur = true,
      blur_popups = true,
      ignore_alpha = 0,
    })

    hl.layer_rule({
      match = {
        namespace = "dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)",
      },
      blur = true,
      ignore_alpha = 0,
    })

    hl.layer_rule({
      match = {
        namespace = "dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)",
      },
      blur = true,
      ignore_alpha = 0,
    })

    ${lib.optionalString cfg.barTheme.enable (barThemes.${cfg.barName} or "")}

  '';
}
