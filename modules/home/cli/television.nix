{
  modules.homeManager.cli = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.television;
  in {
    options.homeManager.cli.television = {
      enable = lib.mkEnableOption "Enable television";
    };
    config = lib.mkIf cfg.enable {
      programs.television = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        settings = {
          tick_rate = 50;
          ui = {
            use_nerd_font_icons = true;
            ui_scale = 120;
            show_preview_panel = true;
          };
        };
      };
    };
  };
}
