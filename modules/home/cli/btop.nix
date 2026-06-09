{
  pkgs,
  host,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  barChoice = vars.barChoice or "";
in {
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
      color_theme = barChoice;
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
}
