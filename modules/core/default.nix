{host, ...}: let
  # Import the host-specific variables.nix
  vars = import ../../hosts/${host}/variables.nix;
  displayManager = vars.displayManager or "tui";
  printEnable = vars.printEnable or false;
  gsrEnable = vars.gsrEnable or false;
  virtEnable = vars.virtEnable or false;
  syncthingEnable = vars.syncthingEnable or false;
  nfsEnable = vars.nfsEnable or false;
  thunarEnable = vars.thunarEnable or false;
  openrgbEnable = vars.openrgbEnable or false;
  steamEnable = vars.steamEnable or false;
  systemThemeEnable = vars.systemThemeEnable or false;
  flatpakEnable = vars.flatpakEnable or false;
  xserverEnable = vars.xserverEnable or false;
  devToolsEnable = vars.devToolsEnable or false;
  cacheEnable = vars.cacheEnable or false;
in {
  imports =
    [
      ./boot.nix
      ./hardware.nix
      ./network.nix
      ./packages.nix
      ./security.nix
      ./services.nix
      ./system.nix
      ./user.nix
    ]
    ++ (
      if displayManager == "tui"
      then [./ly.nix]
      else if displayManager == "silent"
      then [./sddm-silent.nix]
      else [./sddm.nix]
    )
    ++ (
      if devToolsEnable
      then [./nix-ld.nix]
      else []
    )
    ++ (
      if cacheEnable
      then [./cache.nix]
      else []
    )
    ++ (
      if xserverEnable
      then [./xserver.nix]
      else []
    )
    ++ (
      if flatpakEnable
      then [./flatpak.nix]
      else []
    )
    ++ (
      if systemThemeEnable
      then [./fonts.nix ./stylix.nix]
      else []
    )
    ++ (
      if printEnable
      then [./printing.nix]
      else []
    )
    ++ (
      if gsrEnable
      then [./gpu-screen-recorder.nix]
      else []
    )
    ++ (
      if virtEnable
      then [./virtualisation.nix]
      else []
    )
    ++ (
      if syncthingEnable
      then [./syncthing.nix]
      else []
    )
    ++ (
      if nfsEnable
      then [./nfs.nix]
      else []
    )
    ++ (
      if thunarEnable
      then [./thunar.nix]
      else []
    )
    ++ (
      if openrgbEnable
      then [./openrgb.nix]
      else []
    )
    ++ (
      if steamEnable
      then [./steam.nix]
      else []
    );
}
