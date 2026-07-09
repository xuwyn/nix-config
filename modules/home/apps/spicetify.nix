{
  flake.modules.homeManager.apps = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.spicetify;
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    options.homeManager.apps.spicetify = {
      enable = lib.mkEnableOption "Enable Spicetify";
      stylixTheme.enable = lib.mkEnableOption "Whether to apply stylix theme";
    };
    imports = [inputs.spicetify-nix.homeManagerModules.default];
    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (cfg.stylixTheme.enable && config ? stylix) {
        stylix.targets.spicetify.enable = true;
      })
      (lib.mkIf (!cfg.stylixTheme.enable && config ? stylix) {
        stylix.targets.spicetify.enable = false;
        programs.spicetify = {
          theme = spicePkgs.themes.catppuccin;
          colorScheme = "mocha";
        };
      })
      {
        programs.spicetify = {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblockify
            hidePodcasts
            shuffle
          ];
        };
      }
    ]);
  };
}
