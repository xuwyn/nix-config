{
  modules.homeManager.apps = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.obs-studio;
  in {
    options.homeManager.apps.obs-studio = {
      enable = lib.mkEnableOption "Enable OBS";
    };
    config = lib.mkIf cfg.enable {
      programs.obs-studio = {
        enable = true;
        #enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-pipewire-audio-capture
          obs-vkcapture
          obs-source-clone
          obs-move-transition
          obs-composite-blur
          obs-backgroundremoval
        ];
      };
    };
  };
}
