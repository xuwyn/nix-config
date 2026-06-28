{
  flake.modules.nixos.services = {
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.services.nfs;
  in {
    options.nixos.services.nfs = {
      enable = lib.mkEnableOption "Enable NFS";
    };
    config = lib.mkIf cfg.enable {
      services = {
        rpcbind.enable = true;
        nfs.server.enable = true;
      };
    };
  };
}
