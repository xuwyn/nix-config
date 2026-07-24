{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    cfg = config.nixos.desktop;
  in {
    options.nixos.desktop = {
      hyprland.enable = lib.mkEnableOption "Enable Hyprland WM";
      niri.enable = lib.mkEnableOption "Enable Niri WM";
    };
    imports = [inputs.niri-nix.nixosModules.default];
    config = {
      programs = {
        hyprland = {
          enable = cfg.hyprland.enable;
          withUWSM = cfg.hyprland.enable;
        };
        niri = {
          enable = cfg.niri.enable;
          withUWSM = cfg.niri.enable;
          package = pkgs.niri;
        };
      };
    };
  };
}
