{
  modules.nixos.apps = {
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.apps.flatpak;
  in {
    options.nixos.apps.flatpak = {
      enable = lib.mkEnableOption "Enable flatpak for the entire system";
    };

    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

    config = lib.mkIf cfg.enable {
      services.flatpak = {
        enable = true;
        packages = [
        ];
        update.onActivation = true;
      };
    };
  };
}
