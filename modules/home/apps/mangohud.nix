{
  flake.modules.homeManager.apps = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.mangohud;
  in {
    options.homeManager.apps.mangohud = {
      enable = lib.mkEnableOption "Enable Mangohud to limit fps in games";
      fpsLimit = lib.mkOption {
        type = lib.types.ints.positive;
        default = 144;
        description = "Maximum frame rate limit for games (must be greater than 0)";
      };
    };
    config = lib.mkIf cfg.enable {
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
