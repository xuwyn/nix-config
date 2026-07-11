{
  modules.nixos.services = {
    pkgs,
    username,
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
      users.users.${username} = {
        extraGroups = ["lp" "scanner"];
      };

      services = {
        printing = {
          enable = true;
          drivers = [
            # pkgs.hplipWithPlugin
          ];
        };
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        ipp-usb.enable = true;
      };
    };
  };
}
