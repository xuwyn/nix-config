_: let
  mkHjemModule = module: {
    inputs,
    users,
    lib,
    ...
  }: {
    imports = [
      inputs.hjem.${module}.default
      (lib.mkAliasOptionModule ["hj"] ["hjem" "users" (lib.head users)])
    ];
    hjem.clobberByDefault = true;
    hj.enable = true;
  };
in {
  modules = {
    nixos.hjem = mkHjemModule "nixosModules";
    darwin.hjem = mkHjemModule "darwinModules";
  };
}
