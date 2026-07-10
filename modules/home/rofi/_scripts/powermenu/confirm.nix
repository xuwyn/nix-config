{config}: let
  isMatugenEnabled = config.programs.matugen.enable or false;
  colors =
    if isMatugenEnabled
    then {
      base00 = config.programs.matugen.theme.colors.surface.default.color;
      base01 = config.programs.matugen.theme.colors.surface_container_low.default.color;
      base05 = config.programs.matugen.theme.colors.on_surface.default.color;
      base0D = config.programs.matugen.theme.colors.primary.default.color;
      base0B = config.programs.matugen.theme.colors.tertiary.default.color;
      base08 = config.programs.matugen.theme.colors.error.default.color;
    }
    else {
      base00 = "1e1e2e";
      base01 = "181825";
      base05 = "cdd6f4";
      base0D = "89b4fa";
      base0B = "a6e3a1";
      base08 = "f38ba8";
    };
in {
  text = ''
    /**
     *
     * Author : Aditya Shakya (adi1090x)
     * Github : @adi1090x
     *
     * Rofi Theme File
     * Rofi Version: 1.7.3
     **/

    /*****----- Configuration -----*****/
    configuration {
        show-icons:                 false;
    }

    /*****----- Global Properties -----*****/
    * {
      background:     #${colors.base00}FF;
      background-alt: #${colors.base01}FF;
      foreground:     #${colors.base05}FF;
      selected:       #${colors.base0D}FF;
      active:         #${colors.base0B}FF;
      urgent:         #${colors.base08}FF;

      font: "JetBrains Mono Nerd Font 12";
    }

    /*****----- Main Window -----*****/
    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       400px;
        border-radius:               20px;
        cursor:                      "default";
        background-color:            black/50%;
    }

    /*****----- Main Box -----*****/
    mainbox {
        spacing:                     30px;
        padding:                     30px;
        background-color:            transparent;
        children:                    [ "message", "listview" ];
    }

    /*****----- Message -----*****/
    message {
        margin:                      0px;
        padding:                     20px;
        border-radius:               20px;
        background-color:            @background-alt;
        text-color:                  @foreground;
    }
    textbox {
        background-color:            inherit;
        text-color:                  inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
        placeholder-color:           @foreground;
        blink:                       true;
        markup:                      true;
    }

    /*****----- Listview -----*****/
    listview {
        columns:                     2;
        lines:                       1;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;

        spacing:                     30px;
        background-color:            transparent;
        text-color:                  @foreground;
        cursor:                      "default";
    }

    /*****----- Elements -----*****/
    element {
        padding:                     30px 10px;
        border-radius:               20px;
        background-color:            @background-alt;
        text-color:                  @foreground;
        cursor:                      pointer;
    }
    element-text {
        font:                        "JetBrains Mono Nerd Font 48";
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }
    element selected.normal {
        background-color:            var(selected);
        text-color:                  var(background);
    }
  '';
}
