{
  modules.nixos.apps = {
    pkgs,
    inputs,
    users,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.apps.steam;
  in {
    options.nixos.apps.steam = {
      enable = lib.mkEnableOption "Enable steam";
      fpsLimit = lib.mkOption {
        type = lib.types.ints.positive;
        default = 144;
        description = "Maximum fps for games (must be greater than 0)";
      };
    };
    config = lib.mkIf cfg.enable {
      users.users = lib.genAttrs users (name: {
        extraGroups = ["gamemode"];
      });

      programs = {
        steam = {
          enable = true;
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
        gamemode = {
          enable = true;
        };
        gamescope = {
          enable = true;
          capSysNice = true;
          args = [
            "--rt"
            "--expose-wayland"
          ];
        };
      };
    };
  };
}
