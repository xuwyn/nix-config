{
  modules.nixos.drivers = {
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.nixos.drivers.vm;
    in {
      options.nixos.drivers.vm = {
        enable = mkEnableOption "Enable Virtual Machine Guest Services";
      };

      config = mkIf cfg.enable {
        services.qemuGuest.enable = true;
        services.spice-vdagentd.enable = true;
        services.spice-webdavd.enable = false; #Causes build failure davsfs2 unsupported neon version 9-12-25
      };
    };
}
