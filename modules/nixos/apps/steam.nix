{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    users,
    config,
    lib,
    ...
  }: let
    cfg = config.custom.steam;
  in {
    options.custom.steam.fpsLimit = lib.mkOption {
      type = lib.types.ints.positive;
      default = 144;
      description = "Maximum fps for games (must be greater than 0)";
    };

    config = lib.mkMerge [
      {
        programs.steam = {
          enable = lib.mkDefault true;
          package = pkgs.steam.override {
            extraPkgs = pkgs: [pkgs.mangohud];
            extraEnv = {
              MANGOHUD = true;
              MANGOHUD_CONFIG = "no_display,fps_limit=${toString cfg.fpsLimit},vsync=1";
            };
          };
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = false;
          gamescopeSession.enable = true;
          extraCompatPackages = [
            pkgs.proton-ge-bin
          ];
        };
      }

      (lib.mkIf config.programs.steam.enable {
        users.users = lib.genAttrs users (name: {
          extraGroups = ["gamemode"];
        });

        programs.gamemode.enable = true;

        programs.gamescope = {
          enable = true;
          capSysNice = true;
          args = [
            "--rt"
            "--expose-wayland"
          ];
        };
      })
    ];
  };
}
