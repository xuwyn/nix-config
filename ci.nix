{
  lib,
  nixosConfigurations,
  darwinConfigurations,
}: let
  hosts =
    [nixosConfigurations darwinConfigurations]
    |> lib.concatMap (lib.mapAttrsToList (name: cfg: {
      inherit name;
      inherit (cfg.lamina) system;
      toplevel = cfg.config.system.build.toplevel;
    }));

  # { <system> = { <host> = <toplevel>; ... }; ... }
  ciChecks =
    hosts
    |> builtins.groupBy (host: host.system)
    |> builtins.mapAttrs (_: hostsOnSystem:
      hostsOnSystem
      |> map (host: lib.nameValuePair host.name host.toplevel)
      |> builtins.listToAttrs);

  # [ { name; system; } ... ]
  ciMatrix =
    ciChecks
    |> lib.mapAttrsToList (system: checks:
      checks
      |> builtins.attrNames
      |> map (name: {inherit name system;}))
    |> lib.concatLists;
in {
  inherit ciChecks ciMatrix;
}
