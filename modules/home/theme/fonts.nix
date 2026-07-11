{
  modules.homeManager.theme = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.theme.fonts;
  in {
    options.homeManager.theme.fonts = {
      enable = lib.mkEnableOption "Add more fonts to user environment";
      extraFonts = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        description = "Additional host-specific fonts";
      };
    };

    config = lib.mkIf cfg.enable {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs;
        [
          maple-mono.NF
        ]
        ++ cfg.extraFonts;
    };
  };
}
