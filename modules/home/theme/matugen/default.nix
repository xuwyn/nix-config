{
  flake.modules.homeManager.theme = {
    config,
    lib,
    inputs,
    ...
  }: let
    cfg = config.homeManager.theme.matugen;
    matugenDir = "${config.programs.matugen.theme.files}";
  in {
    options.homeManager.theme.matugen = {
      enable = lib.mkEnableOption "Enable matugen color";
      wallpaper = lib.mkOption {
        type = lib.types.path;
        description = "Set matugen wallpaper";
      };
    };
    imports = [inputs.matugen.nixosModules.default];
    config = lib.mkIf cfg.enable {
      programs.matugen = {
        enable = true;
        variant = "dark";
        type = "scheme-fidelity";
        wallpaper = cfg.wallpaper;
        templates = {
          kitty = {
            input_path = ./templates/kitty-colors.conf;
            output_path = "$HOME/.config/kitty/matugen-colors.conf";
          };
          ghostty = {
            input_path = ./templates/ghostty;
            output_path = "$HOME/.config/ghostty/themes/matugen";
          };
          btop = {
            input_path = ./templates/btop.theme;
            output_path = "$HOME/.config/btop/themes/matugen.theme";
          };
          cava = {
            input_path = ./templates/cava-colors.ini;
            output_path = "$HOME/.config/cava/themes/matugen";
          };
          zed = {
            input_path = ./templates/zed-colors.json;
            output_path = "$HOME/.config/zed/themes/matugen-colors.json";
          };
          nvim = {
            input_path = ./templates/nvim.lua;
            output_path = "$HOME/.config/nvim/lua/matugen-colors.lua";
          };
          hyprland = {
            input_path = ./templates/hyprland-colors.lua;
            output_path = "$HOME/.config/hypr/matugen.lua";
          };
          gtk = {
            input_path = ./templates/gtk-colors.css;
            output_path = [
              "$HOME/.config/gtk-3.0/matugen-colors.css"
              "$HOME/.config/gtk-4.0/matugen-colors.css"
            ];
          };
          qt = {
            input_path = ./templates/qtct-colors.conf;
            output_path = [
              "$HOME/.config/qt5ct/colors/matugen-colors.conf"
              "$HOME/.config/qt6ct/colors/matugen-colors.conf"
            ];
          };
          pywalfox = {
            input_path = ./templates/pywalfox-colors.json;
            output_path = "$HOME/.cache/wal/matugen-colors.json";
          };
          discord = {
            input_path = ./templates/midnight-discord.css;
            output_path = "$HOME/.config/Equicord/themes/midnight-discord.css";
          };
          spicetify = {
            input_path = ./templates/spicetify.ini;
            output_path = "$HOME/.config/spicetify/Themes/matugen/color.ini";
          };
        };
      };
      home.file = {
        ".config/kitty/matugen-colors.conf".source = "${matugenDir}/.config/kitty/matugen-colors.conf";
        ".config/ghostty/themes/matugen".source = "${matugenDir}/.config/ghostty/themes/matugen";
        ".config/btop/themes/matugen.theme".source = "${matugenDir}/.config/btop/themes/matugen.theme";
        ".config/cava/themes/matugen".source = "${matugenDir}/.config/cava/themes/matugen";
        ".config/zed/themes/matugen-colors.json".source = "${matugenDir}/.config/zed/themes/matugen-colors.json";
        ".config/nvim/lua/matugen-colors.lua".source = "${matugenDir}/.config/nvim/lua/matugen-colors.lua";
        ".config/hypr/matugen.lua".source = "${matugenDir}/.config/hypr/matugen.lua";
        ".config/gtk-3.0/matugen-colors.css".source = "${matugenDir}/.config/gtk-3.0/matugen-colors.css";
        ".config/gtk-4.0/matugen-colors.css".source = "${matugenDir}/.config/gtk-4.0/matugen-colors.css";
        ".config/qt5ct/colors/matugen-colors.conf".source = "${matugenDir}/.config/qt5ct/colors/matugen-colors.conf";
        ".config/qt6ct/colors/matugen-colors.conf".source = "${matugenDir}/.config/qt6ct/colors/matugen-colors.conf";
        ".cache/wal/matugen-colors.json".source = "${matugenDir}/.cache/wal/matugen-colors.json";
        ".config/Equicord/themes/midnight-discord.css".source = "${matugenDir}/.config/Equicord/themes/midnight-discord.css";
        ".config/spicetify/Themes/matugen/color.ini".source = "${matugenDir}/.config/spicetify/Themes/matugen/color.ini";
      };
    };
  };
}
