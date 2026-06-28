{
  flake.modules.nixos.services = {
    username,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.services.syncthing;
  in {
    options.nixos.services.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing";
    };
    config = lib.mkIf cfg.enable {
      services.syncthing = {
        enable = true;
        user = "${username}";
        dataDir = "/home/${username}";
        configDir = "/home/${username}/.config/syncthing";
      };
    };
  };
}
