{
  modules.nixos.system = {
    lib,
    config,
    pkgs,
    inputs,
    ...
  }: let
    cfg = config.nixos.system;
  in {
    options.nixos.system = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "America/Moncton";
        description = "Set Timezone";
      };
    };

    config = {
      system.stateVersion = "26.05";

      # Localization
      time.timeZone = cfg.timeZone;
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
      };

      # Global environment variables
      environment.variables = {
        NIXOS_OZONE_WL = "1";
      };

      programs = {
        mtr.enable = true; # ping and traceroute
      };

      environment.systemPackages = with pkgs; [
        inxi # system summary
        procps # ps, top, kill
        killall
        wget
        git
        home-manager
      ];
    };
  };
}
