{
  modules.homeManager.cli = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.cli.cava;
    isMatugenEnabled = config.programs.matugen.enable or false;
  in {
    options.homeManager.cli.cava = {
      enable = lib.mkEnableOption "Enable cava";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Set theme for cava";
      };
    };

    config = lib.mkIf cfg.enable {
      xdg.configFile."cava/config".force = true;
      programs.cava = {
        enable = true;
        settings = {
          input =
            if pkgs.stdenv.hostPlatform.isDarwin
            then {
              method = "portaudio";
              source = "BlackHole 2ch";
            }
            else {};

          general = {
            bar_spacing = 1;
            bar_width = 2;
            frame_rate = 60;
          };
          color =
            if cfg.theme != ""
            then {theme = cfg.theme;}
            else if isMatugenEnabled
            then {theme = "matugen";}
            else {
              # Catppuccin Macchiato default
              gradient = 1;
              gradient_color_1 = "'#8bd5ca'";
              gradient_color_2 = "'#91d7e3'";
              gradient_color_3 = "'#7dc4e4'";
              gradient_color_4 = "'#8aadf4'";
              gradient_color_5 = "'#c6a0f6'";
              gradient_color_6 = "'#f5bde6'";
              gradient_color_7 = "'#ee99a0'";
              gradient_color_8 = "'#ed8796'";

              # Dracula
              # gradient = 1;
              # gradient_color_1 = "'#8BE9FD'";
              # gradient_color_2 = "'#9AEDFE'";
              # gradient_color_3 = "'#CAA9FA'";
              # gradient_color_4 = "'#BD93F9'";
              # gradient_color_5 = "'#FF92D0'";
              # gradient_color_6 = "'#FF79C6'";
              # gradient_color_7 = "'#FF6E67'";
              # gradient_color_8 = "'#FF5555'";
            };
        };
      };
    };
  };
}
