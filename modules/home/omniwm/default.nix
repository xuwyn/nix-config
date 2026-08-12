{
  modules.homeManager.omniwm = {
    config,
    lib,
    flake,
    ...
  }: {
    options.homeManager.omniwm = {
      _module_marker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        readOnly = true;
        internal = true;
        visible = false;
        description = "Internal: marks that this module was imported. Do not set manually.";
      };
    };
    config = let
      mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    in {
      # OmniWM replaces the entire file instead of just edit it
      # symlink the entire folder to work around (NOT ideal)
      home.file.".config/omniwm".source =
        mkOutOfStoreSymlink
        "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/omniwm";
    };
  };
}
