{
  flake.modules.homeManager.cli = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.tealdeer;
  in {
    options.homeManager.cli.tealdeer = {
      enable = lib.mkEnableOption "Enable tldr";
    };
    config = lib.mkIf cfg.enable {
      programs.tealdeer = {
        enable = true;
        settings = {
          display.compact = false;
          display.use_pager = true;
          updates.auto_update = true;
        };
      };
    };
  };
}
