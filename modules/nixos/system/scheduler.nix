{
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.custom.scheduler;
  in {
    options.custom.scheduler = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "sched-ext scheduler and ananicy-cpp auto-nice daemon";
      };
    };

    config = lib.mkIf cfg.enable {
      # Please read https://wiki.cachyos.org/configuration/sched-ext/
      services.scx = {
        enable = lib.mkDefault true;
        scheduler = lib.mkDefault "scx_lavd";
        extraArgs = lib.mkDefault ["--autopower"];
      };

      services.ananicy = {
        enable = lib.mkDefault true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
  };
}
