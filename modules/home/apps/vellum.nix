{
  modules.homeManager.apps = {
    config,
    lib,
    inputs,
    ...
  }: let
    cfg = config.homeManager.apps.vellum;
  in {
    imports = [inputs.vellum.homeModules.default];
    options.homeManager.apps.vellum = {
      enable = lib.mkEnableOption "Enable Vellum on-screen annotator";
    };
    config = lib.mkIf cfg.enable {
      services.vellum = {
        enable = true;
        settings = {
          default_tool = "pen";
          remember_last_tool = true;
          stroke_width = 5.0;
          default_color = "#FF0000";
          feedback_duration_ms = 500;
          palette = [
            "#FF0000"
            "#FFFF00"
            "#00FF00"
            "#00FFFF"
            "#0000FF"
            "#FF00FF"
            "#FFFFFF"
            "#000000"
          ];
        };
      };
    };
  };
}
