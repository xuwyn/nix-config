{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    inputs,
    self,
    system,
    ...
  }: let
    cfg = config.custom.desktop;
  in {
    imports = [inputs.umbriel.nixosModules.default];

    options.custom.desktop = {
      noctalia.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Noctalia";
      };
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

    config = let
      wm = self.wrapperModules.${system};
      noctalia = wm.noctalia {inherit (config.custom) desktop;};
      umbriel = wm.umbriel {inherit (config.custom) desktop;};
    in {
      environment.systemPackages =
        [
          pkgs.eog
          pkgs.mpv
          pkgs.rhythmbox
        ]
        ++ lib.optionals cfg.noctalia.enable [
          noctalia
          pkgs.evtest # bongocat
          pkgs.grim # ocr
          pkgs.slurp # ocr
          pkgs.tesseract # ocr
        ]
        ++ lib.optionals config.programs.umbriel.enable [umbriel];

      programs.umbriel = {
        enable = lib.mkDefault true;
        package = umbriel;
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
