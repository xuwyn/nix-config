{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    cfg = config.nixos.desktop;
  in {
    options.nixos.desktop = {
      hyprland.enable = lib.mkEnableOption "Enable Hyprland WM";
      umbriel.enable = lib.mkEnableOption "Enable Umbriel WM";
      startupCommands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Host-specific shell commands to run at WM startup";
      };
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              example = "DP-0";
            };
            width = lib.mkOption {type = lib.types.int;};
            height = lib.mkOption {type = lib.types.int;};
            refresh = lib.mkOption {
              type = lib.types.number;
              default = 60;
            };
            x = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
            y = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
          };
        });
        default = [];
        description = "Monitor settings for WMs";
      };
      terminal = lib.mkOption {
        type = lib.types.enum ["kitty" "ghostty"];
        default = "kitty";
        description = "Choose default terminal";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "Choose default browser";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
        description = "Choose default editor";
      };
    };
    config = {
      environment.variables.NIXOS_OZONE_WL = "1";
      programs = {
        hyprland = {
          enable = cfg.hyprland.enable;
          withUWSM = cfg.hyprland.enable;
        };
        umbriel = {
          enable = cfg.umbriel.enable;
          package = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };
    };
  };
}
