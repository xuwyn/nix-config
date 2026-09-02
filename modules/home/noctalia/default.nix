{
  modules.homeManager.noctalia = {
    pkgs,
    config,
    lib,
    flake,
    inputs,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    options.homeManager.noctalia._module_marker = lib.mkOption {
      type = lib.types.bool;
      default = true;
      readOnly = true;
      internal = true;
      visible = false;
      description = "Internal: marks that this module was imported. Do not set manually.";
    };

    imports = [inputs.noctalia.homeModules.default];

    config = {
      # Install the Noctalia package
      home.packages = [
        pkgs.evtest # read kb input for bongo cat
      ];

      home.file.".local/state/noctalia/settings.toml".source =
        mkOutOfStoreSymlink
        "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/noctalia/settings.toml";

      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = true;
        settings = {
          plugin_settings = {
            "avivbintangaringga/nix-monitor" = {
              clean_command = "nh clean all";
              update_command = "cd ~/${flake.homeRelativePath} && tack update";
            };
          };
          shell = {
            avatar_path = "${config.home.homeDirectory}/.face";
            screenshot = {
              directory = "${config.home.homeDirectory}/Pictures/Screenshots";
            };
          };
        };
      };
    };
  };
}
