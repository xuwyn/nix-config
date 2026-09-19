{
  modules.homeManager.apps = {
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
    };
    imports = [inputs.spicetify-nix.homeManagerModules.default];
    config = lib.mkIf cfg.enable {
      programs.spicetify = {
        enable = true;
        spicetifyPackage = pkgs.spicetify-cli;
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          hidePodcasts
          shuffle
        ];
      };
    };
  };
}
