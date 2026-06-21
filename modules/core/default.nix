{
  host,
  lib,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
in {
  imports =
    [
      ./nix-conf.nix
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
      if (vars.displayManager or "") == ""
      then []
      else if vars.displayManager == "tui"
      then [./ly.nix]
      else [./sddm.nix]
    )
    ++ lib.optional ((vars.qylockTheme or "") != "") ./qylock.nix
    ++ lib.optional (vars.devToolsEnable or false) ./nix-ld.nix
    ++ lib.optional (vars.xserverEnable or false) ./xserver.nix
    ++ lib.optional (vars.flatpakEnable or false) ./flatpak.nix
    ++ lib.optionals (vars.systemThemeEnable or false) [./fonts.nix ./stylix.nix]
    ++ lib.optional (vars.printEnable or false) ./printing.nix
    ++ lib.optional (vars.gsrEnable or false) ./gpu-screen-recorder.nix
    ++ lib.optional (vars.virtEnable or false) ./virtualisation.nix
    ++ lib.optional (vars.syncthingEnable or false) ./syncthing.nix
    ++ lib.optional (vars.nfsEnable or false) ./nfs.nix
    ++ lib.optional (vars.thunarEnable or false) ./thunar.nix
    ++ lib.optional (vars.openrgbEnable or false) ./openrgb.nix
    ++ lib.optional (vars.steamEnable or false) ./steam.nix;
}
