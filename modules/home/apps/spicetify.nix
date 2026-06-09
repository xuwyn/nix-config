{
  pkgs,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  # spicetify-cli with flatpak spotify
  # home.packages = with pkgs; [spicetify-cli];

  imports = [inputs.spicetify-nix.homeManagerModules.default];
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
