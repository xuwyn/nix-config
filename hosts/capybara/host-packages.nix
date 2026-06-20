{pkgs, ...}: {
  imports = [../../modules/home/apps/firefox.nix];
  home.packages = with pkgs; [];
}
