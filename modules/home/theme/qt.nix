{
  flake.modules.homeManager.qt = {
    lib,
    config,
    ...
  }: {
    options.homeManager.qt = {
      stylixTheme.enable = lib.mkEnableOption "Whether to enable stylix theme for qt apps";
    };
    config = {
      qt = {
        enable = true;
        platformTheme.name = lib.mkForce "qtct";
      };
    };
  };
}
