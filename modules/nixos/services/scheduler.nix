{
  modules.nixos.services = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.services.scheduler;
  in {
    options.nixos.services.scheduler = {
      scx = {
        enable = lib.mkEnableOption "Enable sched-ext scheduler";
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
      ananicy = {
        enable = lib.mkEnableOption "Enable ananicy-cpp auto-nice daemon";
      };
    };

    config = lib.mkMerge [
      (lib.mkIf cfg.scx.enable {
        # Please read https://wiki.cachyos.org/configuration/sched-ext/
        services.scx = {
          enable = true;
          scheduler = cfg.scx.scheduler;
          extraArgs = cfg.scx.extraArgs;
        };
      })
      (lib.mkIf cfg.ananicy.enable {
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };
      })
    ];
  };
}
