{types, ...} @ adios: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };
    settings.default = adios.promise ({options}:
      {
        color_theme =
          if options.noctaliaThemeEnabled
          then "noctalia"
          else "dracula";
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
      // options.extraSettings);

    package.default = adios.promise ({inputs}: let
      inherit (inputs.nixpkgs) pkgs;
    in
      if !pkgs.stdenv.hostPlatform.isDarwin
      then
        pkgs.btop.override {
          rocmSupport = true;
          cudaSupport = true;
        }
      else pkgs.btop);
  };
}
