{
  flake.modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.thunar;
  in {
    options.nixos.desktop.thunar = {
      enable = lib.mkEnableOption "Enable Thunar";
    };
    config = lib.mkIf cfg.enable {
      programs.thunar = {
        enable = true;
        plugins = [
          pkgs.thunar-archive-plugin
          pkgs.thunar-volman
        ];
      };
      environment.systemPackages = with pkgs; [
        ffmpegthumbnailer # Need For Video / Image Preview
      ];
    };
  };
}
