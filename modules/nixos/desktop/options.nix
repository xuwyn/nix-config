{
  hjemCompat = true;
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    lib,
    pkgs,
    ...
  }: {
    options.custom.desktop = {
      startupCommands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
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
      };

      cursor = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Ice";
        };
        size = lib.mkOption {
          type = lib.types.str;
          default = "24";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bibata-cursors;
        };
      };

      terminal = lib.mkOption {
        type = lib.types.enum ["kitty" "ghostty"];
        default = "kitty";
      };

      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
      };

      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
      };
    };
  };
}
