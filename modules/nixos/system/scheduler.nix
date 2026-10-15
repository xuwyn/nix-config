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
      scx = {
        scheduler = lib.mkOption {
          type = lib.types.enum ["scx_lavd" "scx_cosmos" "scx_flow" "scx_flash"];
          default = "scx_lavd";
          description = "Choose scheduler, read cachyos wiki for more info";
        };
        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = ["--autopower"];
          description = "Extra arguments passed to the scx scheduler";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      # Please read https://wiki.cachyos.org/configuration/sched-ext/
      services.scx = {
        enable = lib.mkDefault true;
        scheduler = cfg.scx.scheduler;
        extraArgs = cfg.scx.extraArgs;
      };

      services.ananicy = {
        enable = lib.mkDefault true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
  };
}
