{
  inputs,
  host,
  ...
}: let
  # Import the host-specific variables.nix
  vars = import ../../hosts/${host}/variables.nix;
in {
  imports =
    [
      ./boot.nix
      ./xdg.nix
      ./flatpak.nix
      ./fonts.nix
      ./hardware.nix
      ./network.nix
      ./nfs.nix
      ./nh.nix
      ./quickshell.nix
      ./packages.nix
      ./printing.nix
      # Conditionally import the display manager module
      (
        if vars.displayManager == "tui"
        then ./ly.nix
        else if vars.displayManager == "silent"
        then ./sddm-silent.nix
        else ./sddm.nix
      )
      ./security.nix
      ./services.nix
      ./steam.nix
      ./stylix.nix
      ./syncthing.nix
      ./system.nix
      ./thunar.nix
      ./user.nix
      ./virtualisation.nix
      ./xserver.nix
      ./cachix.nix
    ]
    ++ (
      if vars.openrgbEnable
      then [./openrgb.nix]
      else []
    );
}
