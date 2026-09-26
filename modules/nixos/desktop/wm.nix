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
      umbriel.enable = lib.mkEnableOption "Enable Umbriel WM";
    };
    config = {
      environment.variables.NIXOS_OZONE_WL = "1";
      programs = {
        hyprland = {
          enable = cfg.hyprland.enable;
          withUWSM = cfg.hyprland.enable;
        };
        umbriel = {
          enable = cfg.umbriel.enable;
          package = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };
    };
  };
}
