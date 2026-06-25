{
  flake.modules.homeManager.mangohud = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.mangohud;
  in {
    options.homeManager.mangohud = {
      fpsLimit = lib.mkOption {
        type = lib.types.ints.positive;
        default = 144;
        description = "Maximum frame rate limit for games (must be greater than 0)";
      };
    };
    config = {
      programs.mangohud = {
        enable = true;
        enableSessionWide = true;
        settings = {
          no_display = true;
          fps_limit = cfg.fpsLimit;
          vsync = 1;
        };
      };
    };
  };
}
