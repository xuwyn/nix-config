{
  host,
  lib,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
in {
  imports =
    []
    ++ lib.optional (vars.firefoxEnable or false) ./firefox.nix
    ++ lib.optional (vars.flatpakEnable or false) ./flatpak.nix
    ++ lib.optional (vars.nixcordEnable or false) ./nixcord.nix
    ++ lib.optional (vars.obsEnable or false) ./obs.nix
    ++ lib.optional (vars.spicetifyEnable or false) ./spicetify.nix;
}
