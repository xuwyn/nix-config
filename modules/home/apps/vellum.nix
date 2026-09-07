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
          stroke_size = 5.0;
          default_color = "#E84046";
          feedback_duration_ms = 500;
          clear_on_escape = true;
          default_fill_shapes = false;
          palette = [
            "#E84046"
            "#EF8F4F"
            "#EED14D"
            "#4DD54F"
            "#0483FA"
            "#7C58EA"
            "#EBEBEB"
            "#141414"
          ];
        };
      };
    };
  };
}
