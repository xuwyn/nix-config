{
  modules.homeManager.cli = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.btop;
  in {
    options.homeManager.cli.btop = {
      enable = lib.mkEnableOption "Enable btop";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "dracula";
        description = "Set theme for btop";
      };
    };

    config = lib.mkIf cfg.enable {
      xdg.configFile."btop/btop.conf".force = true;
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

        settings = {
          color_theme = cfg.theme;
          theme_background = false;
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
        };
      };
    };
  };
}
