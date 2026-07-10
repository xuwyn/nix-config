{
  flake.modules.homeManager.rofi = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.rofi;
    isMatugenEnabled = config.programs.matugen.enable or false;
    colors =
      if isMatugenEnabled
      then {
        base00 = "#" + config.programs.matugen.theme.colors.surface.default.color;
        base01 = "#" + config.programs.matugen.theme.colors.surface_container_low.default.color;
        base05 = "#" + config.programs.matugen.theme.colors.on_surface.default.color;
        base08 = "#" + config.programs.matugen.theme.colors.error.default.color;
        base09 = "#" + config.programs.matugen.theme.colors.tertiary.default.color;
        base0B = "#" + config.programs.matugen.theme.colors.primary.default.color;
        base0E = "#" + config.programs.matugen.theme.colors.secondary.default.color;
        base0F = "#" + config.programs.matugen.theme.colors.outline.default.color;
      }
      else {
        base00 = "#1e1e2e";
        base01 = "#1e1e2e";
        base05 = "#1e1e2e";
        base08 = "#1e1e2e";
        base09 = "#1e1e2e";
        base0B = "#1e1e2e";
        base0E = "#1e1e2e";
        base0F = "#1e1e2e";

        # base01 = "#181825";
        # base05 = "#cdd6f4";
        # base08 = "#f38ba8";
        # base09 = "#fab387";
        # base0B = "#a6e3a1";
        # base0E = "#cba6f7";
        # base0F = "#f2cdcd";
      };
  in {
    options.homeManager.rofi = {
      background = lib.mkOption {
        type = lib.types.path;
        default = ../../../wallpapers/voyager.png;
        description = "Choose background";
      };
    };
    imports = [
      ./_theme.nix
      ./_scripts
    ];
    config = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
        extraConfig = {
          modi = "drun,filebrowser,run";
          show-icons = true;
          icon-theme = "Papirus";
          font = "JetBrainsMono Nerd Font Mono 12";
          drun-display-format = "{icon} {name}";
          display-drun = " Apps";
          display-run = " Run";
          display-filebrowser = " File";
        };
        theme = let
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            bg = mkLiteral colors.base00;
            bg-alt = mkLiteral colors.base09;
            foreground = mkLiteral colors.base01;
            selected = mkLiteral colors.base08;
            active = mkLiteral colors.base0B;
            text-selected = mkLiteral colors.base00;
            text-color = mkLiteral colors.base05;
            border-color = mkLiteral colors.base0F;
            urgent = mkLiteral colors.base0E;
          };
          "window" = {
            transparency = "real";
            width = mkLiteral "1000px";
            location = mkLiteral "center";
            anchor = mkLiteral "center";
            fullscreen = false;
            x-offset = mkLiteral "0px";
            y-offset = mkLiteral "0px";
            cursor = "default";
            enabled = true;
            border-radius = mkLiteral "15px";
            background-color = mkLiteral "@bg";
          };
          "mainbox" = {
            enabled = true;
            spacing = mkLiteral "0px";
            orientation = mkLiteral "horizontal";
            children = map mkLiteral [
              "imagebox"
              "listbox"
            ];
            background-color = mkLiteral "transparent";
          };
          "imagebox" = {
            padding = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            background-image = mkLiteral ''url("${cfg.background}", height)'';
            orientation = mkLiteral "vertical";
            children = map mkLiteral [
              "inputbar"
              "dummy"
              "mode-switcher"
            ];
          };
          "listbox" = {
            spacing = mkLiteral "20px";
            padding = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            orientation = mkLiteral "vertical";
            children = map mkLiteral [
              "message"
              "listview"
            ];
          };
          "dummy" = {
            background-color = mkLiteral "transparent";
          };
          "inputbar" = {
            enabled = true;
            spacing = mkLiteral "10px";
            padding = mkLiteral "10px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@bg-alt";
            text-color = mkLiteral "@foreground";
            children = map mkLiteral [
              "textbox-prompt-colon"
              "entry"
            ];
          };
          "textbox-prompt-colon" = {
            enabled = true;
            expand = false;
            str = "";
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };
          "entry" = {
            enabled = true;
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "text";
            placeholder = "Search";
            placeholder-color = mkLiteral "inherit";
          };
          "mode-switcher" = {
            enabled = true;
            spacing = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@foreground";
          };
          "button" = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@bg-alt";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "pointer";
          };
          "button selected" = {
            background-color = mkLiteral "@selected";
            text-color = mkLiteral "@foreground";
          };
          "listview" = {
            enabled = true;
            columns = 1;
            lines = 8;
            cycle = true;
            dynamic = true;
            scrollbar = false;
            layout = mkLiteral "vertical";
            reverse = false;
            fixed-height = true;
            fixed-columns = true;
            spacing = mkLiteral "10px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@foreground";
            cursor = "default";
          };
          "element" = {
            enabled = true;
            spacing = mkLiteral "15px";
            padding = mkLiteral "8px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@text-color";
            cursor = mkLiteral "pointer";
          };
          "element normal.normal" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "@text-color";
          };
          "element normal.urgent" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@text-color";
          };
          "element normal.active" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "@text-color";
          };
          "element selected.normal" = {
            background-color = mkLiteral "@selected";
            text-color = mkLiteral "@foreground";
          };
          "element selected.urgent" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@text-selected";
          };
          "element selected.active" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@text-selected";
          };
          "element-icon" = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            size = mkLiteral "36px";
            cursor = mkLiteral "inherit";
          };
          "element-text" = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.0";
          };
          "message" = {
            background-color = mkLiteral "transparent";
          };
          "textbox" = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@bg-alt";
            text-color = mkLiteral "@foreground";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.0";
          };
          "error-message" = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "20px";
            background-color = mkLiteral "@bg";
            text-color = mkLiteral "@foreground";
          };
        };
      };
    };
  };
}
