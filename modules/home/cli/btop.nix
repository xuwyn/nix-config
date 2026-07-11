{
  modules.homeManager.cli = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.btop;
    isMatugenEnabled = config.programs.matugen.enable or false;
  in {
    options.homeManager.cli.btop = {
      enable = lib.mkEnableOption "Enable btop";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
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
            if cfg.theme != ""
            then {color_theme = cfg.theme;}
            else if isMatugenEnabled
            then {color_theme = "matugen";}
            else {color_theme = "dracula";}
          );
      };
    };
  };
}
