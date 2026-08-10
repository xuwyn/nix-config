{
  modules.homeManager.apps = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.apps.mission-center;
  in {
    options.homeManager.apps.mission-center = {
      enable = lib.mkEnableOption "Enable mission-center (task manager gui for linux)";
    };
    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [mission-center];
    };
  };
}
