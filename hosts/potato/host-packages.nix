{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home/apps/firefox.nix
    ../../modules/home/apps/nixcord.nix
    ../../modules/home/apps/spicetify.nix
  ];

  home.packages = [
    # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
