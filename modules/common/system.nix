{
  modules = let
    commonSystemOptions = lib: {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "America/Moncton";
        description = "Set Timezone";
      };
    };
    commonPackages = pkgs: with pkgs; [wget git home-manager];
  in {
    nixos.system = {
      lib,
      config,
      pkgs,
      inputs,
      ...
    }: let
      cfg = config.nixos.system;
    in {
      options.nixos.system = commonSystemOptions lib;

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

        programs = {
          mtr.enable = true; # ping and traceroute
        };

        environment.systemPackages = with pkgs;
          [
            inxi # system summary
            procps # ps, top, kill
            killall
          ]
          ++ commonPackages pkgs;
      };
    };

    darwin.system = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.darwin.system;
    in {
      options.darwin.system = commonSystemOptions lib;

      config = {
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        time.timeZone = cfg.timeZone;

        environment.systemPackages = commonPackages pkgs;
      };
    };
  };
}
