{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [];

  # let caelestia handle these
  programs = {
    btop.enable = lib.mkForce false;
    cava.enable = lib.mkForce false;
  };
}
