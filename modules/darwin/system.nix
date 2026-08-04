{
  modules.darwin.system = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.darwin.system;
  in {
    options.darwin.system = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "America/Moncton";
        description = "Set Timezone";
      };
    };

    config = {
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      time.timeZone = cfg.timeZone;

      environment.systemPackages = with pkgs; [
        wget
        git
        home-manager
      ];
    };
  };
}
