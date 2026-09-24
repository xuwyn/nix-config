{types, ...}: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };

    settings.defaultFunc = {options}:
      {
        color_theme = "dracula";
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
      }
      // options.extraSettings;

    package.defaultFunc = {inputs}: let
      inherit (inputs.nixpkgs) pkgs;
    in
      if !pkgs.stdenv.hostPlatform.isDarwin
      then
        pkgs.btop.override {
          rocmSupport = true;
          cudaSupport = true;
        }
      else pkgs.btop;
  };
}
