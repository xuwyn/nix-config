{
  flake.modules.homeManager.theme = {
    inputs,
    username,
    pkgs,
    config,
    lib,
    ...
  }: let
    hyprlandEnable = config.homeManager.hyprland.enable or false;
    i3Enable = config.homeManager.i3.enable or false;
    cfg = config.homeManager.theme.stylix;
  in {
    options.homeManager.theme.stylix = {
      enable = lib.mkEnableOption "Enable home stylix";
      image = lib.mkOption {
        type = lib.types.path;
        description = "Set stylix image relative path";
      };
    };
    imports = [inputs.stylix.homeModules.stylix];
    config = lib.mkIf cfg.enable {
      stylix =
        {
          enable = true;
          image = cfg.image;
          opacity.terminal = 0.95;
          polarity = "dark";
          targets = {
            starship.enable = false; # let starship use terminal colors
            zed.enable = false; # bug not fixed, hardcoded theme for zed
            nixvim.enable = false; # use catppuccin with stylix color override
            gnome.enable = false;
            waybar.enable = false;
            rofi.enable = false;
            hyprland.enable = false;
            hyprlock.enable = false;
            kde.enable = false;
          };
        }
        // (
          if hyprlandEnable || i3Enable
          then {
            cursor = {
              package = pkgs.bibata-cursors;
              name = "Bibata-Modern-Ice";
              # package = pkgs.nordzy-cursor-theme;
              # name = "Nordzy-cursors";
              size = 24;
            };
            icons = {
              enable = true;
              package = pkgs.papirus-icon-theme;
              dark = "Papirus-Dark";
              light = "Papirus-Light";
            };
            fonts = {
              monospace = {
                package = pkgs.nerd-fonts.jetbrains-mono;
                name = "JetBrains Mono";
              };
              sansSerif = {
                # package = pkgs.maple-mono.NF;
                # name = "Maple Mono NF";
                package = pkgs.nerd-fonts.noto;
                name = "Noto Sans";
              };
              serif = {
                package = pkgs.nerd-fonts.noto;
                name = "Noto Serif";
              };
              sizes = {
                applications = 12;
                terminal = 15;
                desktop = 11;
                popups = 12;
              };
            };
          }
          else {}
        );
    };
  };
}
