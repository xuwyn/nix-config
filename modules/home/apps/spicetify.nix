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
    isStylixEnabled = config.homeManager.theme.stylix.enable or false;
  in {
    options.homeManager.apps.spicetify = {
      enable = lib.mkEnableOption "Enable Spicetify";
    };
    imports = [inputs.spicetify-nix.homeManagerModules.default];
    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (isStylixEnabled && config ? stylix) {
        stylix.targets.spicetify = {
          enable = true;
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
          # theme = spicePkgs.themes.catppuccin;
          # colorScheme = "mocha";
        };
      }
    ]);
  };
}
