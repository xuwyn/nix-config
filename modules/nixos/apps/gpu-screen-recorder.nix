{
  modules.nixos.apps = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.apps.gpu-screen-recorder;
  in {
    options.nixos.apps.gpu-screen-recorder = {
      enable = lib.mkEnableOption "Enable gpu-screen-recorder";
    };
    config = lib.mkIf cfg.enable {
      programs.gpu-screen-recorder = {
        enable = true;
        package = pkgs.gpu-screen-recorder;
      };
    };
  };
}
