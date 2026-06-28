{
  flake.modules.homeManager.cli = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.btop;
    isStylixEnabled = config.homeManager.theme.stylix.enable or false;
  in {
    options.homeManager.cli.btop = {
      enable = lib.mkEnableOption "Enable btop";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Set theme for btop";
      };
      stylixTheme.enable = lib.mkEnableOption "Enable Stylix theme for btop, overrides default theme";
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        programs.btop = {
          enable = true;
          package =
            if !pkgs.stdenv.hostPlatform.isDarwin
            then
              pkgs.btop.override {
                rocmSupport = true;
                cudaSupport = true;
              }
            else pkgs.btop;

          settings =
            {
              vim_keys = true;
              rounded_corners = true;
              proc_tree = true;
              show_gpu_info = "on";
              show_uptime = true;
              show_coretemp = true;
              cpu_sensor = "auto";
              show_disks = true;
              only_physical = true;
              io_mode = true;
              io_graph_combined = false;
            }
            // (
              if cfg.theme != "" && !cfg.stylixTheme.enable
              then {color_theme = cfg.theme;}
              else {}
            );
        };
      }
      (lib.mkIf (isStylixEnabled && (config ? stylix)) {
        xdg.configFile."btop/btop.conf".force = true;

        stylix.targets.btop = {
          enable = true;
          colors.enable = cfg.stylixTheme.enable;
          opacity.enable = true;
        };
      })
    ]);
  };
}
