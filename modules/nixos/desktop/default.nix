{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    inputs,
    self,
    ...
  }: let
    cfg = config.nixos.desktop;
  in {
    options.nixos.desktop = {
      noctalia.enable = lib.mkEnableOption "Enable Noctalia";
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
    imports = [inputs.umbriel.nixosModules.default];
    config = let
      wm = self.wrapperModules.${pkgs.stdenv.hostPlatform.system};
      noctalia = wm.noctalia {inherit (config.nixos) desktop;};
      umbriel = wm.umbriel {inherit (config.nixos) desktop;};
    in {
      # environment.variables.NIXOS_OZONE_WL = "1"; # TODO: duplicated with WM's environment
      environment.systemPackages =
        lib.optionals cfg.noctalia.enable [
          noctalia
          pkgs.evtest # bongocat
          pkgs.grim # ocr
          pkgs.slurp # ocr
          pkgs.tesseract # ocr
        ]
        ++ lib.optionals cfg.umbriel.enable [umbriel];
      programs = {
        hyprland = {
          enable = cfg.hyprland.enable;
          withUWSM = cfg.hyprland.enable;
        };
        umbriel = {
          enable = cfg.umbriel.enable;
          package = umbriel;
        };
      };
      # TODO: move this somewhere else that makes more sense
      hj.xdg.config.files."umbriel/config.toml".source = umbriel.configFile;

      # wallpapers and pfp
      hj.files = {
        "Pictures/Wallpapers".source = "${inputs.assets}/wallpapers";
        ".face".source = "${inputs.assets}/face.jpg";
      };
    };
  };
}
