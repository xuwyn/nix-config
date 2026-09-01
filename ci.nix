{
  config,
  lib,
  ...
}: let
  categories = {
    nixosConfigurations = cfg: cfg.config.system.build.toplevel;
    darwinConfigurations = cfg: cfg.config.system.build.toplevel;
    homeConfigurations = cfg: cfg.activationPackage;
  };

  mkGroup = attr: valueOf:
    lib.foldl' (
      acc: name: let
        cfg = config.${attr}.${name};
        system = cfg.pkgs.stdenv.hostPlatform.system;
      in
        acc // {${system} = (acc.${system} or {}) // {${name} = valueOf cfg;};}
    ) {} (builtins.attrNames config.${attr});

  checks = lib.foldl' lib.recursiveUpdate {} (lib.mapAttrsToList mkGroup categories);
in {
  ciChecks = checks;
  ciMatrix = lib.concatMap (
    system: map (name: {inherit name system;}) (builtins.attrNames checks.${system})
  ) (builtins.attrNames checks);
}
