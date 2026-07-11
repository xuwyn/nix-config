{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.hyprland;
  in {
    options.nixos.desktop.hyprland = {
      enable = lib.mkEnableOption "Enable Hyprland for Desktop";
    };
    config = lib.mkIf cfg.enable {
      programs = {
        seahorse.enable = true;
        localsend.enable = true;

        hyprland = {
          enable = true; # set this so desktop file is created
          withUWSM = true;
        };

        # hyprlock.enable = true;
      };
    };
  };
}
