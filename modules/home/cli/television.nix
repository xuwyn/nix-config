{
  modules.homeManager.cli = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.television;
    matugenEnabled = config.programs.matugen.enable or false;
    c = role: fallback:
      if matugenEnabled
      then "#" + config.programs.matugen.theme.colors.${role}.default.color
      else fallback;
  in {
    options.homeManager.cli.television = {
      enable = lib.mkEnableOption "Enable television";
    };
    config = lib.mkIf cfg.enable {
      homeManager.cli.search.enable = lib.mkDefault true;
      programs.television = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        settings = {
          tick_rate = 50;
          ui = {
            theme = "matugen";
            use_nerd_font_icons = true;
            ui_scale = 120;
            show_preview_panel = true;
          };
        };
        themes = {
          matugen = {
            action_picker_mode_bg = c "tertiary" "magenta";
            action_picker_mode_fg = c "on_tertiary" "black";
            border_fg = c "outline" "bright-black";
            channel_mode_bg = c "secondary" "green";
            channel_mode_fg = c "on_secondary" "black";
            dimmed_text_fg = c "on_surface_variant" "white";
            input_text_fg = c "primary" "bright-red";
            match_fg = c "tertiary" "bright-red";
            preview_title_fg = c "secondary" "bright-magenta";
            remote_control_mode_bg = c "error" "yellow";
            remote_control_mode_fg = c "on_error" "black";
            result_count_fg = c "outline_variant" "bright-red";
            result_line_number_fg = c "outline" "bright-yellow";
            result_name_fg = c "on_surface" "bright-blue";
            result_value_fg = c "on_surface_variant" "white";
            selection_bg = c "secondary" "bright-black";
            selection_fg = c "on_secondary" "bright-green";
            send_to_channel_mode_fg = c "tertiary" "cyan";
            text_fg = c "on_surface" "bright-blue";
          };
        };
      };
    };
  };
}
