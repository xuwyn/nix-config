{
  inputs,
  users,
  lib,
  system,
  ...
}: let
  class =
    if lib.hasSuffix "-darwin" system
    then "darwinModules"
    else "nixosModules";
in {
  imports = [
    inputs.hjem.${class}.default
    (lib.mkAliasOptionModule ["hj"] ["hjem" "users" (lib.head users)])
  ];

  hjem.clobberByDefault = true;
  hj.enable = true;
}
