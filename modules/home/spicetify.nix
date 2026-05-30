{
  pkgs,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  # disable spicetify (home) for now and install spicetify-cli
  home.packages = with pkgs; [spicetify-cli];

  imports = [inputs.spicetify-nix.homeManagerModules.default];
  programs.spicetify = {
    enable = false;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    # theme = spicePkgs.themes.catppuccin;
    # colorScheme = "mocha";
  };
}
