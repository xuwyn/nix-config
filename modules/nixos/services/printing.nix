{
  flake.modules.nixos.printing = {
    pkgs,
    username,
    ...
  }: {
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
}
