{
  modules.homeManager.i3 = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.homeManager.i3 = {
      _module_marker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        readOnly = true;
        internal = true;
        visible = false;
        description = "Internal: marks that this module was imported. Do not set manually.";
      };
    };

    imports = [
      ./_binds.nix
      ./_windowcommands.nix
      ./_startup.nix
      ./_packages.nix
      ./_scripts
      ./_picom.nix
      ./_dunst.nix
      ./_polybar.nix
    ];

    config = {
      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3;

        config = {
          bars = [];

          # Remove title bars for all windows
          window = {
            border = 1;
            titlebar = false;
          };

          floating = {
            border = 1;
            titlebar = false;
          };

          gaps = {
            inner = 5;
            outer = 5;
          };
        };

        extraConfig = ''
          default_border pixel 1
          for_window [class=".*"] border pixel 1
          title_align center
        '';
      };
    };
  };
}
