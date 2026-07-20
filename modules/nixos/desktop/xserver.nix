{
  modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.nixos.desktop.xserver;
  in {
    options.nixos.desktop.xserver = {
      enable = lib.mkEnableOption "Enable xserver";
    };
    config = lib.mkIf cfg.enable {
      services.xserver = {
        enable = true;
        excludePackages = [pkgs.xterm];
      };
    };
  };
}
