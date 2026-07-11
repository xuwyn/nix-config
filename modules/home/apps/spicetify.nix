{
  modules.homeManager.apps = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.spicetify;
    isMatugenEnabled = config.programs.matugen.enable or false;
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    options.homeManager.apps.spicetify = {
      enable = lib.mkEnableOption "Enable Spicetify";
    };
    imports = [inputs.spicetify-nix.homeManagerModules.default];
    config = lib.mkIf cfg.enable {
      programs.spicetify =
        {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblockify
            hidePodcasts
            shuffle
          ];
        }
        // (
          if isMatugenEnabled
          then {
            theme = {
              name = "matugen";
              src = "${config.programs.matugen.theme.files}/.config/spicetify/Themes/matugen";
            };
          }
          else {
            theme = spicePkgs.themes.catppuccin;
            colorScheme = "mocha";
          }
        );
    };
  };
}
