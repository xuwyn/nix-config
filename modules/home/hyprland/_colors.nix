{config, ...}: let
  cfg = config.homeManager;
  inherit (cfg.desktop) bar;
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
  wayland.windowManager.hyprland.extraConfig = ''${barThemes.${bar} or ""}'';
}
