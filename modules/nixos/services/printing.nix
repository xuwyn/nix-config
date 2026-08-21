{
  modules.nixos.services = {
    pkgs,
    users,
    lib,
    config,
    ...
  }: let
    cfg = config.nixos.services.printing;
  in {
    options.nixos.services.printing = {
      enable = lib.mkEnableOption "Enable printing service";
    };

    config = lib.mkIf cfg.enable {
      users.users = lib.genAttrs users (name: {
        extraGroups = ["lp" "scanner"];
      });
      services = {
        printing = {
          enable = true;
          drivers = [
            # pkgs.hplipWithPlugin
          ];
        };
        ipp-usb.enable = true;
      };
    };
  };
}
