{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/home/apps/firefox.nix
    ../../modules/home/xdg
  ];
  home.packages = with pkgs; [];

  # let caelestia handle these
  programs = {
    btop.enable = lib.mkForce false;
    cava.enable = lib.mkForce false;
  };
}
