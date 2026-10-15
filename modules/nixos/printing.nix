{
  platforms = ["linux"];
  module = {
    pkgs,
    users,
    lib,
    config,
    ...
  }: {
    options.custom.printing.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "CUPS printing, SANE scanning, and ipp-usb";
    };

    config = lib.mkIf config.custom.printing.enable {
      hardware.sane = {
        enable = true;
        extraBackends = [pkgs.sane-airscan];
        disabledDefaultBackends = ["escl"];
      };

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
