{
  flake.modules.homeManager.btop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.btop;
  in {
    options.homeManager.btop = {
      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Set theme for btop";
      };
      stylixTheme.enable = lib.mkEnableOption "Enable Stylix theme for btop, overrides default theme";
    };
    config = {
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
    };
  };
}
